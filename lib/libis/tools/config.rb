# encoding: utf-8
require 'singleton'
require 'set'
require 'yaml'
require 'erb'
require 'logger'

require 'libis/tools/extend/hash'

module Libis
  module Tools

    # The Config class is a convenience method for easy configuration maintenance and loading.
    # It supports code defaults, loading configurations from multiple YAML files containing ERB statements.
    # The Config class follows the Singleton pattern and behaves like a Hash/OpenStruct/HashWithIndifferentAccess.
    # It also initializes a default Logger instance.
    # The class also stores a system-wide {::Logger} instance that will be used by {::Libis::Tools::Logger}.
    #
    # The parameters can be accessed by getter/setter method or using the Hash syntax:
    #
    #         require 'libis/tools/config'
    #         cfg = ::Libis::Tools::Config
    #         cfg['my_value'] = 10
    #         p cfg.instance.my_value # => 10
    #         cfg.instance.my_text = 'abc'
    #         p cfg[:my_text] # => 'abc'
    #         p cfg.logger.warn('message') # => W, [2015-03-16T12:51:01.180548 #28935]  WARN -- : message
    #
    class Config
      include Singleton

      class << self

        private

        # For each configuration parameter, the value can be accessed via the class or the Singleton instance.
        def method_missing(name, *args, &block)
          instance.send(name, *args, &block)
        end

      end

      # Load configuration parameters from a YAML file or Hash.
      #
      # The YAML file can contain ERB syntax values that will be evaluated at loading time. Multiple files can be
      # loaded. Instead of a YAML file, a Hash can be passed. The file paths and Hashes are memorised and loaded again
      # by the {#reload} methods.
      # @param [String,Hash] file_or_hash
      def <<(file_or_hash)
        return if file_or_hash.nil?
        hash = case file_or_hash
                 when Hash
                   @sources << file_or_hash
                   file_or_hash
                 when String
                   return unless File.exist?(file_or_hash)
                   @sources << File.absolute_path(file_or_hash)
                   data = ERB.new(open(file_or_hash).read).result
                   # noinspection RubyResolve
                   YAML.load(data).to_hash rescue {}
                 else
                   {}
               end
        @data.merge! hash.key_symbols_to_strings recursive: true
        self
      end

      # Load all files and Hashes again. Will not reset the configuration parameters. Parameters set directly on the
      # configuration are kept intact unless they also exist in the files or hashes in which case they will be overwritten.
      def reload
        sources = @sources.dup
        @sources.clear
        sources.each { |f| self << f }
        self
      end

      # Load all files and Hashes again. All configuration parameters are first deleted which means that any parameters
      # added directly (not via file or hash) will no longer be available. Parameters set explicitly that also exist in
      # the files or hashes will be reset to the values in those files and hashes.
      def reload!
        @data.clear
        reload
      end

      # Get the value of a parameter.
      # @param [String, Symbol] name parameter name
      # @return [Object] parameter value; nil if the parameter does not exist
      def [](name)
        @data.fetch(name.to_s) rescue nil
      end

      # Set the value of a parameter.
      # If the parameter does not yet exist, it will be created.
      # @param (see #[])
      # @param [Object] value the new value for the parameter
      # @return [Object] parameter value
      def []=(name, value)
        @data.store(name.to_s, value)
      end

      # Return the ::Logger instance.
      def logger
        @logger
      end

      # Set the ::Logger instance.
      # @param [::Logger] my_logger new logger instance
      def logger=(my_logger)
        @logger = my_logger
      end

      # Set the ::Logger instance's formatter.
      # If the supplied formatter is missing or nil, a default formatter will be applied. The default formatter prints
      # log lines like this:
      #
      #     <first char of severity>, [<timestamp>#<process-id>] <severity> -- <program_name> : <message>
      #
      # @param [Proc] formatter the formatter procedure or nil for default formatter
      def set_log_formatter(formatter = nil)
        logger.formatter = formatter || proc do |severity, time, progname, msg|
          "%s, [%s#%d] %5s -- %s: %s\n" % [severity[0..0],
                                           (time.strftime('%Y-%m-%dT%H:%M:%S.') << '%06d ' % time.usec),
                                           $$, severity, progname, msg]
        end
      end

      private

      def method_missing(name, *args)
        key = name.to_s
        if name.to_s =~ /^(.*)=$/
          key = $1
        end
        if @data.has_key?(key)
          if key =~/^\w+$/ # not all key names are safe to use as method names
            self.instance_eval <<-END
              def #{key}
                self['#{key}']
              end
              def #{name}=(value)
                self['#{name}'] = value
              end
            END
          end
        end
        key == name.to_s ? @data.fetch(key) : @data.store(key, args.first)
      end

      def initialize
        @data = Hash.new
        @sources = Array.new
        @logger = ::Logger.new(STDOUT)
        set_log_formatter
      end

    end
  end
end

