# encoding: utf-8
require 'singleton'
require 'yaml'
require 'erb'
require 'logging'

require_relative 'config_file'

module Libis
  module Tools

    # The Singleton Config class is a convenience class for easy configuration maintenance, loading and saving.
    # It also initializes a default logger and supports creating extra loggers. The logging infrastructure is based on
    # the {http://www.rubydoc.info/gems/logging/Logging ::Logging} gem and supports the {::Libis::Tools::Logger} class.
    #
    # For the configuration parameters, it supports code defaults, loading configurations from multiple YAML files
    # containing ERB statements. The Config class behaves like a Hash/OpenStruct/HashWithIndifferentAccess.
    #
    # The parameters can be accessed by getter/setter method or using the Hash syntax:
    #
    #         require 'libis/tools/config'
    #         cfg = ::Libis::Tools::Config
    #         cfg['my_value'] = 10
    #         p cfg.instance.my_value # => 10
    #         cfg.instance.my_text = 'abc'
    #         p cfg[:my_text] # => 'abc'
    #         p cfg.logger.warn('message') # => W, [2015-03-16T12:51:01.180548 #123.456]  WARN : message
    #
    class Config
      include Singleton

      class << self

        private

        # For each configuration parameter, the value can be accessed via the class or the Singleton instance.
        # The class diverts to the instance automatically.
        def method_missing(name, *args, &block)
          result = instance.send(name, *args, &block)
          self === result ? self : result
        end

      end

      # Instance method that allows to access the configuration parameters by method.
      def method_missing(name, *args, &block)
        result = config.send(name, *args, &block)
        self === config ? self : result
      end

      # Load configuration parameters from a YAML file or Hash.
      #
      # The file paths and Hashes are memorised and loaded again by the {#reload} methods.
      # @param [String,Hash] file_or_hash
      def <<(file_or_hash)
        sync do
          @config.send('<<', (file_or_hash)) { |data| @sources << data }
          self
        end
      end

      # Load all files and Hashes again.
      #
      # Will not reset the configuration parameters. Parameters set directly on the
      # configuration are kept intact unless they also exist in the files or hashes in which case they will be overwritten.
      def reload
        sync do
          sources = @sources.dup
          @sources.clear
          sources.each { |f| self << f }
          self
        end
      end

      # Clear data and load all files and Hashes again.
      #
      # All configuration parameters are first deleted which means that any parameters
      # added directly (not via file or hash) will no longer be available. Parameters set explicitly that also exist in
      # the files or hashes will be reset to the values in those files and hashes.
      def reload!
        sync do
          @config.clear!
          reload
        end
      end

      # Clear all data.
      #
      # Not only all configuration parameters are deleted, but also the memorized list of loaded files
      # and hashes are cleared and the logger configuration is reset to it's default status.
      def clear!
        sync do
          @config.clear!
          @sources = Array.new
          self.logger
          self
        end
      end

      # Gets the default ::Logging formatter.
      #
      # This in an instance of a layout that prints in the default message format.
      #
      # The default layout prints log lines like this:
      #
      #     <first char of severity>, [<timestamp> #<process-id>.<thread-id] <severity> : <message>
      #
      def get_log_formatter
        # noinspection RubyResolve
        ::Logging::Layouts::Pattern.new(DEFAULT_LOG_LAYOUT_PARAMETERS)
      end

      def logger(name = nil, appenders = nil)
        sync do
          name ||= 'root'
          logger = ::Logging.logger[name]
          if logger.appenders.empty?
            logger.appenders = appenders || ::Logging.appenders.stdout(layout: get_log_formatter)
          end
          logger
        end
      end

      attr_accessor :config, :sources

      protected

      def initialize(hash = nil, opts = {})
        @mutex = ReentrantMutex.new
        @config = ConfigFile.new(hash, opts)
        self.clear!
      end

      def sync(&block)
        @mutex.synchronize(&block)
      end

      ::Logging::init
      # noinspection RubyResolve
      DEFAULT_LOG_LAYOUT_PARAMETERS = {
          pattern: "%.1l, [%d #%p.%t] %5l%X{Application}%X{Subject} : %m\n",
          date_pattern: '%Y-%m-%dT%H:%M:%S.%L'
      }

    end
  end
end
