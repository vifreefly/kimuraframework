require 'thor'

module Kimurai
  class CLI < Thor
    map %w[--version -v] => :__print_version

    desc "generate", "Generator, available types: project, spider, schedule"
    def generate(generator_type, *args)
      case generator_type
      when "project"
        project_name = args.shift
        raise "Provide project name to generate a new project" unless project_name.present?
        Generator.new.generate_project(project_name)
      when "spider"
        spider_name = args.shift
        raise "Provide spider name to generate a spider" unless spider_name.present?
        Generator.new.generate_spider(spider_name, in_project: inside_project?)
      when "schedule"
        Generator.new.generate_schedule
      else
        raise "Don't know this generator type: #{generator_type}"
      end
    end

    ###

    desc "setup", "Setup server"
    option :port, aliases: :p, type: :string, banner: "Port for ssh connection"
    option "ask-sudo", type: :boolean, banner: "Provide sudo password for a user to install system-wide packages"
    option "ask-auth-pass", type: :boolean, banner: "Auth using password"
    option "ssh-key-path", type: :string, banner: "Auth using ssh key"
    option :local, type: :boolean, banner: "Run setup on a local machine (Ubuntu only)"
    def setup(user_host)
      command = AnsibleCommandBuilder.new(user_host, options, playbook: "setup").get

      pid = spawn *command
      Process.wait pid
    end

    desc "deploy", "Deploy project to the server and update cron schedule"
    option :port, aliases: :p, type: :string, banner: "Port for ssh connection"
    option "ask-auth-pass", type: :boolean, banner: "Auth using password"
    option "ssh-key-path", type: :string, banner: "Auth using ssh key"
    option "repo-url", type: :string, banner: "Repo url"
    option "repo-key-path", type: :string, banner: "SSH key for a git repo"
    def deploy(user_host)
      if !`git status --short`.empty?
        raise "Deploy: Please commit your changes first"
      elsif `git remote`.empty?
        raise "Deploy: Please add remote origin repository to your repo first"
      elsif !`git rev-list master...origin/master`.empty?
        raise "Deploy: Please push your commits to the remote origin repo first"
      end

      repo_url = options["repo-url"] ? options["repo-url"] : `git remote get-url origin`.strip
      repo_name = repo_url[/\/([^\/]*)\.git/i, 1]

      command = AnsibleCommandBuilder.new(user_host, options, playbook: "deploy",
        vars: { repo_url: repo_url, repo_name: repo_name, repo_key_path: options["repo-key-path"] }
      ).get

      pid = spawn *command
      Process.wait pid
    end

    ###

    desc "crawl", "Run a particular spider by it's name"
    def crawl(spider_name)
      raise "Can't find Kimurai project" unless inside_project?
      require './config/boot'

      unless klass = Kimurai.find_by_name(spider_name)
        raise "Can't find spider with name `#{spider_name}` in the project. " \
          "To list all available spiders, run: `$ bundle exec kimurai list`"
      end

      # Set time_zone if exists
      if time_zone = Kimurai.configuration.time_zone
        Kimurai.time_zone = time_zone
      end

      klass.crawl!
    end

    desc "parse", "Parse url in the particular spider method"
    option :url, type: :string, required: true, banner: "Url to pass to the method"
    def parse(spider_name, method_name)
      raise "Can't find Kimurai project" unless inside_project?
      require './config/boot'

      unless klass = Kimurai.find_by_name(spider_name)
        raise "Can't find spider with name `#{spider_name}` in the project. " \
          "To list all available spiders, run: `$ bundle exec kimurai list`"
      end

      klass.parse!(method_name, url: options["url"])
    end

    desc "console", "Start Kimurai console"
    option :engine, type: :string, banner: "Engine to use"
    option :url, type: :string, banner: "Url to process"
    def console(spider_name = nil)
      require 'pry'
      require './config/boot' if inside_project?

      if spider_name
        raise "Can't find Kimurai project" unless inside_project?

        unless klass = Kimurai.find_by_name(spider_name)
          raise "Can't find spider with name `#{spider_name}` in the project. " \
            "To list all available spiders, run: `$ bundle exec kimurai list`"
        end
      else
        klass = inside_project? ? ApplicationSpider : ::Kimurai::Base
      end

      engine = options["engine"]&.delete(":")&.to_sym
      if url = options["url"]
        klass.new(engine).request_to(:console, url: options["url"])
      else
        klass.new(engine).public_send(:console)
      end
    end

    desc "list", "List all available spiders in the current project"
    def list
      raise "Can't find Kimurai project" unless inside_project?
      require './config/boot'

      Kimurai.list.keys.each { |name| puts name }
    end

    desc "runner", "Run all spiders in the project in queue"
    option :include, type: :array, default: [], banner: "List of spiders to run"
    option :exclude, type: :array, default: [], banner: "List of spiders to exclude from run"
    option :jobs, aliases: :j, type: :numeric, default: 1, banner: "The number of concurrent jobs"
    def runner
      raise "Can't find Kimurai project" unless inside_project?

      jobs = options["jobs"]
      raise "Jobs count can't be 0" if jobs == 0

      require './config/boot'
      require 'kimurai/runner'

      spiders = options["include"].presence || Kimurai.list.keys
      spiders -= options["exclude"]

      Runner.new(spiders, jobs).run!
    end

    desc "--version, -v", "Print the version"
    def __print_version
      puts VERSION
    end

    desc "dashboard", "Run dashboard"
    def dashboard
      raise "Can't find Kimurai project" unless inside_project?

      require './config/boot'
      if Object.const_defined?("Kimurai::Dashboard")
        require 'kimurai/dashboard/app'
        Kimurai::Dashboard::App.run!
      else
        raise "Kimurai::Dashboard is not defined"
      end
    end

    private

    def inside_project?
      Dir.exists?("spiders") && File.exists?("./config/boot.rb")
    end
  end
end

require_relative 'cli/generator'
require_relative 'cli/ansible_command_builder'
