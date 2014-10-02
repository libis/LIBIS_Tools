# encoding: utf-8

require 'backports'

module LIBIS
  module Tools

    module Logger

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

      def message(severity, msg, *args)
        message_text = (msg % args rescue ((msg + ' - %s') % args.to_s))
        appname = Config.appname
        appname = self.name if self.respond_to? :name
        appname = self.class.name if (appname.nil? or appname == '')
        Config.logger.add(severity, message_text, appname)
      end

    end

  end
end
