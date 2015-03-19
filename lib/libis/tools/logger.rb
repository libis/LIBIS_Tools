# encoding: utf-8

require 'backports'
require 'libis/tools/config'
require 'libis/tools/extend/string'

module Libis
  module Tools

    # The Logger module adds logging functionality to any class.
    #
    # Just include the ::Libis::Tools::Logger module and the methods debug, info, warn, error and fatal will be
    # available to the class instance. Each method takes a message argument and optional extra parameters.
    #
    # The methods all call the {#message} method with the logging level as first argument and the supplied arguments
    # appended.
    module Logger

      def self.included(klass)
        klass.class_eval do

          def debug(msg, *args)
            return if (self.options[:quiet] rescue false)
            message ::Logger::DEBUG, msg, *args
          end

          def info(msg, *args)
            return if (self.options[:quiet] rescue false)
            message ::Logger::INFO, msg, *args
          end

          def warn(msg, *args)
            return if (self.options[:quiet] rescue false)
            message ::Logger::WARN, msg, *args
          end

          def error(msg, *args)
            message ::Logger::ERROR, msg, *args
          end

          def fatal(msg, *args)
            message ::Logger::FATAL, msg, *args
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
          def message(severity, msg, *args)
            message_text = (msg % args rescue ((msg + ' - %s') % args.to_s))
            appname = Config.appname
            appname = self.name if self.respond_to? :name
            appname = self.class.name if appname.blank?
            Config.logger.add(severity, message_text, appname)
          end

        end
      end

    end

  end
end
