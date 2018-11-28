module Kimurai
  class Base
    class Storage
      attr_reader :database

      def initialize
        @mutex = Mutex.new
        @database = {}
      end

      def all(scope = nil)
        @mutex.synchronize do
          scope ? database.fetch(scope, []) : database
        end
      end

      def include?(scope, value)
        @mutex.synchronize do
          database[scope] ||= []
          database[scope].include?(value)
        end
      end

      def add(scope, value)
        @mutex.synchronize do
          database[scope] ||= []
          if value.kind_of?(Array)
            database[scope] += value
            database[scope].uniq!
          else
            database[scope].push(value) unless database[scope].include?(value)
          end
        end
      end

      ###

      def unique?(scope, value)
        @mutex.synchronize do
          database[scope] ||= []
          database[scope].include?(value) ? false : database[scope].push(value) and true
        end
      end

      ###

      def clear!
        @mutex.synchronize do
          @database = {}
        end
      end
    end
  end
end
