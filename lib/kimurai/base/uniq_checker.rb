module Kimurai
  class Base
    class UniqChecker
      def initialize
        @database = []
        @mutex = Mutex.new
      end

      def unique?(scope, value)
        @mutex.synchronize do
          @database[scope] ||= []
          if @database[scope].include?(value)
            false
          else
            @database[scope].push(value)
            true
          end
        end
      end
    end
  end
end
