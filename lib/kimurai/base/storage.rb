module Kimurai
  class Base
    class Storage
      def initialize
        @database = {}
        @mutex = Mutex.new
      end

      def all(scope = nil)
        @mutex.synchronize do
          scope ? (@database[scope] || []) : @database
        end
      end

      def include?(scope, value)
        @mutex.synchronize do
          @database[scope] ||= []
          @database[scope].include?(value)
        end
      end

      def add(scope, value)
        @mutex.synchronize do
          @database[scope] ||= []
          @database[scope].push(value) unless @database[scope].include?(value)
        end
      end

      ###

      def unique?(scope, value)
        @mutex.synchronize do
          @database[scope] ||= []
          @database[scope].include?(value) ? false : @database[scope].push(value) and true
        end
      end
    end
  end
end
