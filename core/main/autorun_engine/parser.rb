#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module AutorunEngine
      class Parser
        include Singleton

        def initialize
          @config = BeEF::Core::Configuration.instance
        end

        BROWSER = %w[FF C IE S O ALL]
        OS = %w[Linux Windows OSX Android iOS BlackBerry ALL]
        VERSION = ['<', '<=', '==', '>=', '>', 'ALL', 'Vista', 'XP']
        CHAIN_MODE = %w[sequential nested-forward]
        MAX_VER_LEN = 15
        # Parse a JSON ARE file and returns an Hash with the value mappings
        def parse(name, author, browser, browser_version, os, os_version, modules, exec_order, exec_delay, chain_mode)
          success = [true]

          return [false, 'Illegal chain_mode definition'] unless CHAIN_MODE.include?(chain_mode)
          return [false, 'Illegal rule name'] unless BeEF::Filters.is_non_empty_string?(name)
          return [false, 'Illegal author name'] unless BeEF::Filters.is_non_empty_string?(author)

          # if multiple browsers were specified, check each browser
          if browser.is_a?(Array)
            browser.each do |b|
              return [false, 'Illegal browser definition'] unless BROWSER.include?(b)
            end
          # else, if only one browser was specified, check browser and browser version
          else
            return [false, 'Illegal browser definition'] unless BROWSER.include?(browser)

            if browser_version != 'ALL' && !(VERSION.include?(browser_version[0, 2].gsub(/\s+/, '')) &&
                  BeEF::Filters.is_valid_browserversion?(browser_version[2..-1].gsub(/\s+/, '')) && browser_version.length < MAX_VER_LEN)
              return [false, 'Illegal browser_version definition']
            end
          end

          if os_version != 'ALL' && !(VERSION.include?(os_version[0, 2].gsub(/\s+/, '')) &&
                  BeEF::Filters.is_valid_osversion?(os_version[2..-1].gsub(/\s+/, '')) && os_version.length < MAX_VER_LEN)
            return [false, 'Illegal os_version definition']
          end

          return [false, 'Illegal os definition'] unless OS.include?(os)

          # check if module names, conditions and options are ok
          modules.each do |cmd_mod|
            mod = BeEF::Core::Models::CommandModule.where(name: cmd_mod['name']).first
            if mod.nil?
              return [false, "The specified module name (#{cmd_mod['name']}) does not exist"]
            else
              modk = BeEF::Module.get_key_by_database_id(mod.id)
              mod_options = BeEF::Module.get_options(modk)

              opt_count = 0
              mod_options.each do |opt|
                if opt['name'] == cmd_mod['options'].keys[opt_count]
                  opt_count += 1
                else
                  return [false, "The specified option (#{cmd_mod['options'].keys[opt_count]
                                                        }) for module (#{cmd_mod['name']}) does not exist"]
                end
              end
            end
          end

          exec_order.each { |order| return [false, 'execution_order values must be Integers'] unless order.is_a?(Integer) }
          exec_delay.each { |delay| return [false, 'execution_delay values must be Integers'] unless delay.is_a?(Integer) }

          return [false, 'execution_order and execution_delay values must be consistent with modules numbers'] unless
              modules.size == exec_order.size && modules.size == exec_delay.size

          success
        rescue StandardError => e
          print_error e.message.to_s
          print_debug e.backtrace.join("\n").to_s
          [false, 'Something went wrong.']
        end
      end
    end
  end
end
