require 'optparse'
require 'io/console'
require 'active_support/core_ext/hash'

module Rmega
  module CLI
    module Helpers
      def cli_options
        $cli_options ||= {options: {}}
      end

      def cli_prompt_password
        print("Enter password: ")
        password = STDIN.noecho(&:gets)
        password = password[0..-2] if password.end_with?("\n")
        puts

        return password
      end

      def scan_mega_urls(text)
        text.to_s.scan(Nodes::Factory::URL_REGEXP).flatten.map { |s| "https://mega.co.nz/##{s}" }
      end

      def mega_url?(url)
        Nodes::Factory.url?(url)
      end

      def configuration_filepath
        File.expand_path('~/.rmega')
      end

      def write_configuration_file
        opts = {options: cli_options[:options]}
        if cli_options[:user]
          opts[:user] = cli_options[:user]
          opts[:pass] = cli_options[:pass] || cli_prompt_password
        end
        File.open(configuration_filepath, 'wb') { |file| file.write(opts.to_json) }
        FileUtils.chmod(0600, configuration_filepath)
        puts "Options saved into #{configuration_filepath}"
      end

      def read_configuration_file
        if File.exists?(configuration_filepath)
          opts = JSON.parse(File.read(configuration_filepath))
          $cli_options = opts.deep_symbolize_keys.deep_merge(cli_options)
          puts "Loaded configuration file #{configuration_filepath}" if cli_options[:debug]
        end
      rescue Exception => ex
        raise(ex) if cli_options[:debug]
      end

      def apply_cli_options
        Rmega.logger.level = ::Logger::DEBUG if cli_options[:debug]

        cli_options[:options].each do |key, value|
          Rmega.options.__send__("#{key}=", value)
        end
      end

      def apply_opt_parser_options(opts)
        opts.on("-t NUM", "--thread_pool_size", "Number of threads to use") { |n|
          cli_options[:options][:thread_pool_size] = n.to_i
        }

        opts.on("--proxy-addr ADDRESS", "Http proxy address") { |value|
          cli_options[:options][:http_proxy_address] = value
        }

        opts.on("--proxy-port PORT", "Http proxy port") { |value|
          cli_options[:options][:http_proxy_port] = value.to_i
        }

        opts.on("-u", "--user USER_EMAIL", "User email address") { |value|
          cli_options[:user] = value
        }

        opts.on("--pass [USER_PASSWORD]", "User password (if omitted will prompt for it)") { |value|
          cli_options[:pass] = value
        }

        opts.on("--write-cfg", "Write a configuration file with the given options") {
          cli_options[:write_cfg] = true
        }

        opts.on("--debug", "Debug mode") {
          cli_options[:debug] = true
        }

        opts.on("-v", "--version", "Print the version number") {
          puts Rmega::VERSION
          puts Rmega::HOMEPAGE
          exit
        }
      end

      def humanize_bytes(*args)
        Progress.humanize_bytes(*args)
      end

      def rescue_errors_and_inerrupt(&block)
        if cli_options[:write_cfg]
          write_configuration_file
        else
          read_configuration_file
          apply_cli_options
          yield
        end
      rescue Interrupt
        puts "\nInterrupted"
      rescue Exception => ex
        if cli_options[:debug]
          raise(ex)
        else
          puts "\nError: #{ex.message}"
        end
      end
    end
  end
end
