module Kimurai
  class CLI
    class Generator < Thor::Group
      include Thor::Actions

      def self.source_root
        File.dirname(File.expand_path('..', __FILE__))
      end

      def generate_project(project_name)
        directory "template", project_name
        inside(project_name) do
          run "bundle install"
          run "git init"
        end
      end

      def generate_spider(spider_name, in_project:)
        spider_path = in_project ? "spiders/#{spider_name}.rb" : "./#{spider_name}.rb"
        raise "Spider #{spider_path} already exists" if File.exists? spider_path

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

        unless in_project
          insert_into_file spider_path, "  @engine = :mechanize\n", after: "@name = \"#{spider_name}\"\n"
          prepend_to_file spider_path, "require 'kimurai'\n\n"
          append_to_file spider_path, "\n#{spider_class}.crawl!"
        end
      end

      def generate_schedule
        copy_file "template/config/schedule.rb", "./schedule.rb"
      end

      private

      def to_spider_class(string)
        string.sub(/^./) { $&.capitalize }
          .gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }
          .gsub(/(?:-|(\/))([a-z\d]*)/) { "Dash#{$2.capitalize}" }
          .gsub(/(?:\.|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }
      end
    end
  end
end
