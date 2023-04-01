#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
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

        # Load an ARE rule set
        # @param [Hash] ARE ruleset as JSON
        # @return [Hash] {"success": Boolean, "rule_id": Integer, "error": String}
        def load_rule_json(data)
          name = data['name'] || ''
          author = data['author'] || ''
          browser = data['browser'] || 'ALL'
          browser_version = data['browser_version'] || 'ALL'
          os = data['os'] || 'ALL'
          os_version = data['os_version'] || 'ALL'
          modules = data['modules']
          execution_order = data['execution_order']
          execution_delay = data['execution_delay']
          chain_mode = data['chain_mode'] || 'sequential'

          begin
            BeEF::Core::AutorunEngine::Parser.instance.parse(
              name,
              author,
              browser,
              browser_version,
              os,
              os_version,
              modules,
              execution_order,
              execution_delay,
              chain_mode
            )
          rescue => e
            print_error("[ARE] Error loading ruleset (#{name}): #{e.message}")
            return { 'success' => false, 'error' => e.message }
          end

          existing_rule = BeEF::Core::Models::Rule.where(
            name: name,
            author: author,
            browser: browser,
            browser_version: browser_version,
            os: os,
            os_version: os_version,
            modules: modules.to_json,
            execution_order: execution_order.to_s,
            execution_delay: execution_delay.to_s,
            chain_mode: chain_mode
          ).first

          unless existing_rule.nil?
            msg = "Duplicate rule already exists in the database (ID: #{existing_rule.id})"
            print_info("[ARE] Skipping ruleset (#{name}): #{msg}")
            return { 'success' => false, 'error' => msg }
          end

          are_rule = BeEF::Core::Models::Rule.new(
            name: name,
            author: author,
            browser: browser,
            browser_version: browser_version,
            os: os,
            os_version: os_version,
            modules: modules.to_json,
            execution_order: execution_order.to_s,
            execution_delay: execution_delay.to_s,
            chain_mode: chain_mode
          )
          are_rule.save

          print_info("[ARE] Ruleset (#{name}) parsed and stored successfully.")

          if @debug_on
            print_more "Target Browser: #{browser} (#{browser_version})"
            print_more "Target OS: #{os} (#{os_version})"
            print_more 'Modules to run:'
            modules.each do |mod|
              print_more "(*) Name: #{mod['name']}"
              print_more "(*) Condition: #{mod['condition']}"
              print_more "(*) Code: #{mod['code']}"
              print_more '(*) Options:'
              mod['options'].each do |key, value|
                print_more "\t#{key}: (#{value})"
              end
            end
            print_more "Exec order: #{execution_order}"
            print_more "Exec delay: #{exec_delay}"
          end

          { 'success' => true, 'rule_id' => are_rule.id }
        rescue TypeError, ArgumentError => e
          print_error("[ARE] Failed to load ruleset (#{name}): #{e.message}")
          { 'success' => false, 'error' => e.message }
        end

        # Load an ARE ruleset from file
        # @param [String] JSON ARE ruleset file path
        def load_rule_file(json_rule_path)
          rule_file = File.open(json_rule_path, 'r:UTF-8', &:read)
          self.load_rule_json(JSON.parse(rule_file))
        rescue => e
          print_error("[ARE] Failed to load ruleset from #{json_rule_path}: #{e.message}")
        end

        # Load all JSON ARE rule files from arerules/enabled/ directory
        def load_directory
          Dir.glob("#{$root_dir}/arerules/enabled/**/*.json") do |rule_file|
            print_debug("[ARE] Processing ruleset file: #{rule_file}")
            load_rule_file(rule_file)
          end
        end
      end
    end
  end
end
