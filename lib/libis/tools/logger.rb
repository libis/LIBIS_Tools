# encoding: utf-8

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
        Config.logger.add(severity, message_text, Config.appname)
      end

    end

  end
end
