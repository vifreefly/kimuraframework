require 'cliver'

module Kimurai
  class CLI
    class AnsibleCommandBuilder
      def initialize(user_host, options, playbook:, vars: {})
        @user_host = user_host
        @options = options
        @playbook = playbook
        @vars = vars
      end

      def get
        unless Cliver.detect("ansible-playbook")
          raise "Can't find `ansible-playbook` executable, to install: " \
            "Mac OS X: `$ brew install ansible`, Ubuntu: `$ sudo apt install ansible`"
        end

        user = @user_host[/(.*?)\@/, 1]
        host = @user_host[/\@(.+)/, 1] || @user_host
        inventory = @options["port"] ? "#{host}:#{@options['port']}," : "#{host},"

        gem_dir = Gem::Specification.find_by_name("kimurai").gem_dir
        playbook_path = gem_dir + "/lib/kimurai/automation/" + "#{@playbook}.yml"

        command = [
          "ansible-playbook", playbook_path,
          "--inventory", inventory,
          "--ssh-extra-args", "-oForwardAgent=yes",
          "--connection", @options["local"] ? "local" : "smart",
          "--extra-vars", "ansible_python_interpreter=/usr/bin/python3"
        ]

        if File.exists? "config/automation.yml"
          require 'yaml'
          if config = YAML.load_file("config/automation.yml").dig(@playbook)
            config.each { |key, value| @vars[key] = value unless @vars[key] }
          end
        end

        @vars.each do |key, value|
          next unless value.present?
          command.push "--extra-vars", "#{key}=#{value}"
        end

        if user
          command.push "--user", user
        end

        if @options["ask-sudo"]
          command.push "--ask-become-pass"
        end

        if @options["ask-auth-pass"]
          unless Cliver.detect("sshpass")
            raise "Can't find `sshpass` executable for password authentication, to install: " \
              "Mac OS X: `$ brew install http://git.io/sshpass.rb`, Ubuntu: `$ sudo apt install sshpass`"
          end

          command.push "--ask-pass"
        end

        if ssh_key_path = @options["ssh-key-path"]
          command.push "--private-key", ssh_key_path
        end

        command
      end
    end
  end
end
