require 'json'
require 'csv'

module Kimurai
  class Base
    class SimpleSaver
      def initialize
        @index = 0
        @mutex = Mutex.new
      end

      def save(path, item, format:, position:)
        @mutex.synchronize do
          @index += 1
          item[:position] = @index if position

          case format
          when :json
            save_to_json(item, path)
          when :pretty_json
            save_to_pretty_json(item, path)
          when :jsonlines
            save_to_jsonlines(item, path)
          when :csv
            save_to_csv(item, path)
          else
            raise "SimpleSaver: wrong type of format: #{format}"
          end
        end
      end

      private

      def save_to_json(item, path)
        data = JSON.generate([item])

        if @index > 1
          file_content = File.read(path).sub(/\}\]\Z/, "\}\,")
          File.open(path, "w") do |f|
            f.write(file_content + data.sub(/\A\[/, ""))
          end
        else
          File.open(path, "w") { |f| f.write(data) }
        end
      end

      def save_to_pretty_json(item, path)
        data = JSON.pretty_generate([item])

        if @index > 1
          file_content = File.read(path).sub(/\}\n\]\Z/, "\}\,\n")
          File.open(path, "w") do |f|
            f.write(file_content + data.sub(/\A\[\n/, ""))
          end
        else
          File.open(path, "w") { |f| f.write(data) }
        end
      end

      def save_to_jsonlines(item, path)
        data = JSON.generate(item)

        if @index > 1
          File.open(path, "a") { |file| file.write("\n" + data) }
        else
          File.open(path, "w") { |file| file.write(data) }
        end
      end

      def save_to_csv(item, path)
        data = flatten_hash(item)

        if @index > 1
          CSV.open(path, "a+", force_quotes: true) do |csv|
            csv << data.values
          end
        else
          CSV.open(path, "w", force_quotes: true) do |csv|
            csv << data.keys
            csv << data.values
          end
        end
      end

      def flatten_hash(hash)
        hash.each_with_object({}) do |(k, v), h|
          if v.is_a? Hash
            flatten_hash(v).map { |h_k, h_v| h["#{k}.#{h_k}"] = h_v }
          else
            h[k&.to_s] = v
          end
        end
      end
    end
  end
end


