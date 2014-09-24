# encoding: utf-8
require 'singleton'
require 'logger'

module LIBIS
  module Tools

    class Config
      include Singleton

      def Config.appname
        instance.appname
      end

      def Config.appname=(name)
        instance.appname = name
      end

      def Config.logger
        instance.logger
      end

      def Config.logger=(my_logger)
        instance.logger = my_logger
      end

      def Config.set_formatter(formatter = nil)
        @logger.formatter = formatter || proc do |severity, time, progname, msg|
          "%s, [%s#%d] %5s -- %s: %s\n" % [severity[0..0],
                                           (time.strftime('%Y-%m-%dT%H:%M:%S.') << '%06d ' % time.usec),
                                           $$, severity, progname, msg]
        end
      end

      def initialize
        @logger = ::Logger.new(STDOUT)
        @appname = ''
        self.class.set_formatter
      end

    end

  end
end
