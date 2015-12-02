# encoding: utf-8
require 'singleton'
require 'yaml'
require 'erb'
require 'logger'

require 'libis/tools/config_file'

module Libis
  module Tools

    # The Config class is a convenience class for easy configuration maintenance, loading and saving.
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
          result = instance.send(name, *args, &block)
          self === result ? self : result
        end

      end

      def method_missing(name, *args, &block)
        result = config.send(name, *args, &block)
        self === config ? self : result
      end

      # Load configuration parameters from a YAML file or Hash.
      #
      # The file paths and Hashes are memorised and loaded again by the {#reload} methods.
      # @param [String,Hash] file_or_hash
      def <<(file_or_hash)
        @config.send('<<', (file_or_hash)) { |data| @sources << data }
        self
      end

      # Load all files and Hashes again.
      #
      # Will not reset the configuration parameters. Parameters set directly on the
      # configuration are kept intact unless they also exist in the files or hashes in which case they will be overwritten.
      def reload
        sources = @sources.dup
        @sources.clear
        sources.each { |f| self << f }
        self
      end

      # Clear data and load all files and Hashes again.
      #
      # All configuration parameters are first deleted which means that any parameters
      # added directly (not via file or hash) will no longer be available. Parameters set explicitly that also exist in
      # the files or hashes will be reset to the values in those files and hashes.
      def reload!
        @config.clear!
        reload
      end

      # Clear all data.
      #
      # Not only all configuration parameters are deleted, but also the memorized list of loaded files
      # and hashes are cleared and the logger configuration is reset to it's default status.
      def clear!
        @config.clear!
        @sources = Array.new
        @logger = ::Logger.new(STDOUT)
        set_log_formatter
        self
      end

      # Set the ::Logger instance's formatter.
      # If the supplied formatter is missing or nil, a default formatter will be applied. The default formatter prints
      # log lines like this:
      #
      #     <first char of severity>, [<timestamp>#<process-id>] <severity> -- <program_name> : <message>
      #
      # @param [Proc] formatter the formatter procedure or nil for default formatter
      def set_log_formatter(formatter = nil)
        self.logger.formatter = formatter || proc do |severity, time, progname, msg|
          "%s, [%s#%d] %5s -- %s: %s\n" % [severity[0..0],
                                           (time.strftime('%Y-%m-%dT%H:%M:%S.') << '%06d ' % time.usec),
                                           $$, severity, progname, msg]
        end
      end

      attr_accessor :logger, :config, :sources

      protected

      def initialize(hash = nil, opts = {})
        @config = ConfigFile.new(hash, opts)
        self.clear!
      end

    end
  end
end

