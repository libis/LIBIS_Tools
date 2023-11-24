# encoding: utf-8

require 'libis/tools/config'
require 'libis/tools/extend/string'

module Libis
  module Tools

    # This module adds logging functionality to any class.
    #
    # Just include the ::Libis::Tools::Logger module and the methods debug, info, warn, error and fatal will be
    # available to the class instance. Each method takes a message argument and optional extra parameters.
    #
    # It is possible to overwrite the {#logger} method with your own implementation to use
    # a different logger for your class.
    #
    # The methods all call the {#message} method with the logging level as first argument
    # and the supplied arguments appended.
    #
    # Example:
    #
    #     require 'libis/tools/logger'
    #     class TestLogger
    #       include ::Libis::Tools::Logger
    #       attr_accessor :options, name
    #     end
    #     tl = TestLogger.new
    #     tl.debug 'message'
    #     tl.warn 'message'
    #     tl.error 'huge error: [%d] %s', 1000, 'Exit'
    #     tl.info 'Running application: %s', t.class.name
    #
    # produces:
    #     D, [...] DEBUG : message
    #     W, [...]  WARN : message
    #     E, [...] ERROR : huge error: [1000] Exit
    #     I, [...]  INFO : Running application TestLogger
    #
    module Logger

      # Get the logger instance
      #
      # Default implementation is to get the root logger from the Config, but can be overwritten for sub-loggers.
      # @!method(logger)
      def logger
        ::Libis::Tools::Config.logger
      end

      def set_application(name = nil)
        name ||= self.class.name
        ::Logging.mdc['Application'] = name.blank? ? '' : " -- #{name}"
      end

      def set_subject(name = nil)
        ::Logging.mdc['Subject'] = name.blank? ? '' : " - #{name}"
      end

      # Send a debug message to the logger.
      #
      # If the optional extra parameters are supplied, the first parameter will be interpreted as a format
      # specification. It's up to the caller to make sure the format specification complies with the number and
      # types of the extra arguments. If the format substitution fails, the message will be printed as:
      # '<msg> - [<args>]'.
      #
      # @param [String] msg the message.
      # @param [Array] args optional extra arguments.
      # @param [Hash] kwargs optional keyword arguments
      # @!method(debug(msg, *args, **kwargs))
      def debug(msg, *args, **kwargs)
        self.message :DEBUG, msg, *args, **kwargs
      end

      # Send an info message to the logger.
      #
      # (see #debug)
      # @param (see #debug)
      # @!method(info(msg, *args, **kwargs))
      def info(msg, *args, **kwargs)
        self.message :INFO, msg, *args, **kwargs
      end

      # Send a warning message to the logger.
      #
      # (see #debug)
      # @param (see #debug)
      # @!method(warn(msg, *args, **kwargs))
      def warn(msg, *args, **kwargs)
        self.message :WARN, msg, *args, **kwargs
      end

      # Send an error message to the logger.
      #
      # (see #debug)
      # @param (see #debug)
      # @!method(error(msg, *args, **kwargs))
      def error(msg, *args, **kwargs)
        self.message :ERROR, msg, *args, **kwargs
      end

      # Send a fatal message to the logger.
      #
      # (see #debug)
      # @param (see #debug)
      # @!method(fatal_error(msg, *args, **kwargs))
      def fatal_error(msg, *args, **kwargs)
        self.message :FATAL, msg, *args, **kwargs
      end

      # The method that performs the code logging action.
      #
      # If extra arguments are supplied, the message string is expected to be a format specification string and the
      # extra arguments will be applied to it.
      #
      # This default message method implementation uses the logger of ::Libis::Tools::Config. If an 'appname'
      # parameter is defined in the Config object, it will be used as program name by the logger, otherwise the
      # class name is taken.
      #
      # @param [{::Logger::Severity}] severity
      # @param [String] msg message string
      # @param [Object] args optional list of extra arguments
      # @oaram [Hash] kwargs optional list of extra keyword arguments
      # @!method(message(severity, msg, *args, **kwargs))
      def message(severity, msg, *args, **kwargs)
        message_text = (msg % args rescue "#{msg}#{args.empty? ? '' : " - #{args}"}")
        self.logger.add(::Logging.level_num(severity), message_text)
      end

    end

  end
end
