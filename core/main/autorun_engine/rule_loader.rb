#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module AutorunEngine

      class RuleLoader

        include Singleton

        def initialize
          @config = BeEF::Core::Configuration.instance
          @debug_on = @config.get('beef.debug')
        end

        # this expects parsed JSON as input
        def load(data)
          begin

            name = data['name']
            author = data['author']
            browser = data['browser']||'ALL'
            browser_version = data['browser_version']||'ALL'
            os = data['os']||'ALL'
            os_version = data['os_version']||'ALL'
            modules = data['modules']
            exec_order = data['execution_order']
            exec_delay = data['execution_delay']
            chain_mode = data['chain_mode']

            parser_result = BeEF::Core::AutorunEngine::Parser.instance.parse(
                name,author,browser,browser_version,os,os_version,modules,exec_order,exec_delay,chain_mode)

            if parser_result.length == 1 && parser_result.first
              print_info "[ARE] Ruleset (#{name}) parsed and stored successfully."
              if @debug_on
                print_more "Target Browser: #{browser} (#{browser_version})"
                print_more "Target OS: #{os} (#{os_version})"
                print_more "Modules to Trigger:"
                         modules.each do |mod|
                            print_more "(*) Name: #{mod['name']}"
                            print_more "(*) Condition: #{mod['condition']}"
                            print_more "(*) Code: #{mod['code']}"
                            print_more "(*) Options:"
                            mod['options'].each do |key,value|
                              print_more "\t#{key}: (#{value})"
                            end
                         end
                print_more "Exec order: #{exec_order}"
                print_more "Exec delay: #{exec_delay}"
              end
              are_rule = BeEF::Core::AutorunEngine::Models::Rule.new(
                  :name => name,
                  :author => author,
                  :browser => browser,
                  :browser_version => browser_version,
                  :os => os,
                  :os_version => os_version,
                  :modules => modules.to_json,
                  :execution_order => exec_order,
                  :execution_delay => exec_delay,
                  :chain_mode => chain_mode)
              are_rule.save
              return { 'success' => true, 'rule_id' => are_rule.id}
            else
              print_error "[ARE] Ruleset (#{name}): ERROR. " + parser_result.last
              return { 'success' => false, 'error' => parser_result.last }
            end

          rescue => e
            err = 'Malformed JSON ruleset.'
            print_error "[ARE] Ruleset (#{name}): ERROR. #{e} #{e.backtrace}"
            return { 'success' => false, 'error' => err }
          end
        end

        def load_file(json_rule_path)
          begin
            rule_file = File.open(json_rule_path, 'r:UTF-8', &:read)
            self.load JSON.parse(rule_file)
          rescue => e
            print_error "[ARE] Failed to load ruleset from #{json_rule_path}"
          end
        end

        def load_directory
          Dir.glob("#{$root_dir}/arerules/enabled/**/*.json") do |rule|
            print_debug "[ARE] Processing rule: #{rule}"
            self.load_file rule
          end
        end
      end
    end
  end
end
