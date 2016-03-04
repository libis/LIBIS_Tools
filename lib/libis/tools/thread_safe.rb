require 'monitor'

module Libis
  module Tools

    # Module to safely create a mutex for creating thread safe classes.
    #
    # Usage: include this module in a class or extend a module with this one.
    module ThreadSafe

      # Access the instance mutex
      def mutex
        self.class.class_mutex.synchronize do
          @mutex ||= Monitor.new
        end
      end

      # @!visibility private
      module MutexCreator
        attr_accessor :class_mutex
      end

      # @!visibility private
      def self.included(klass)
        klass.extend(MutexCreator)
        # noinspection RubyResolve
        klass.class_mutex = Monitor.new
      end
    end
  end
end