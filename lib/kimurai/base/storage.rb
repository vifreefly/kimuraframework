require 'pstore'

module Kimurai
  class Base
    class Storage
      attr_reader :database, :path

      def initialize(path = nil)
        @path = path
        @mutex = Mutex.new
        @database = path ? PStore.new(path) : {}
      end

      def all(scope = nil)
        @mutex.synchronize do
          if path
            database.transaction { scope ? database.fetch(scope, []) : database }
          else
            scope ? database.fetch(scope, []) : database
          end
        end
      end

      def include?(scope, value)
        @mutex.synchronize do
          if path
            database.transaction do
              database[scope] ||= []
              database[scope].include?(value)
            end
          else
            database[scope] ||= []
            database[scope].include?(value)
          end
        end
      end

      def add(scope, value)
        @mutex.synchronize do
          if path
            database.transaction do
              database[scope] ||= []
              if value.class == Array
                database[scope] += value
                database[scope].uniq!
              else
                database[scope].push(value) unless database[scope].include?(value)
              end
            end
          else
            database[scope] ||= []
            if value.class == Array
              database[scope] += value
              database[scope].uniq!
            else
              database[scope].push(value) unless database[scope].include?(value)
            end
          end
        end
      end

      ###

      def unique?(scope, value)
        @mutex.synchronize do
          if path
            database.transaction do
              database[scope] ||= []
              database[scope].include?(value) ? false : database[scope].push(value) and true
            end
          else
            database[scope] ||= []
            database[scope].include?(value) ? false : database[scope].push(value) and true
          end
        end
      end

      ###

      def clear!
        @mutex.synchronize do
          if path
            database.transaction do
              database.roots.each { |key| database.delete key }
            end
          else
            database = {}
          end
        end
      end

      def delete!
        @mutex.synchronize do
          if path
            File.delete path if File.exists? path
          end
        end
      end
    end
  end
end
