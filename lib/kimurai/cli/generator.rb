module Kimurai
  class CLI
    class Generator < Thor::Group
      include Thor::Actions

      def self.source_root
        File.dirname(File.expand_path(__dir__))
      end

      def generate_project(project_name)
        directory 'template', project_name
        inside(project_name) do
          run 'bundle install'
          run 'git init'
        end
      end

      def generate_spider(spider_name, in_project:)
        spider_path = in_project ? "spiders/#{spider_name}.rb" : "./#{spider_name}.rb"
        raise "Spider #{spider_path} already exists" if File.exist? spider_path

        spider_class = to_spider_class(spider_name)
        create_file spider_path do
          <<~RUBY
            class #{spider_class} < #{in_project ? 'ApplicationSpider' : 'Kimurai::Base'}
              @name = "#{spider_name}"
              @start_urls = []
              @config = {}

              def parse(response, url:, data: {})
              end
            end
          RUBY
        end

        return if in_project

        insert_into_file spider_path, "  @engine = :mechanize\n", after: "@name = \"#{spider_name}\"\n"
        prepend_to_file spider_path, "require 'kimurai'\n\n"
        append_to_file spider_path, "\n#{spider_class}.crawl!"
      end

      def generate_schedule
        copy_file 'template/config/schedule.rb', './schedule.rb'
      end

      private

      def to_spider_class(string)
        string.sub(/^./) { ::Regexp.last_match(0).capitalize }
              .gsub(%r{(?:_|(/))([a-z\d]*)}) { "#{::Regexp.last_match(1)}#{::Regexp.last_match(2).capitalize}" }
              .gsub(%r{(?:-|(/))([a-z\d]*)}) { "Dash#{::Regexp.last_match(2).capitalize}" }
              .gsub(%r{(?:\.|(/))([a-z\d]*)}) { "#{::Regexp.last_match(1)}#{::Regexp.last_match(2).capitalize}" }
      end
    end
  end
end
