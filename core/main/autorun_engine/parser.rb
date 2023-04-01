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

        def parse(name, author, browser, browser_version, os, os_version, modules, execution_order, execution_delay, chain_mode)
          raise ArgumentError, "Invalid rule name: #{name}" unless BeEF::Filters.is_non_empty_string?(name)
          raise ArgumentError, "Invalid author name: #{author}" unless BeEF::Filters.is_non_empty_string?(author)
          raise ArgumentError, "Invalid chain_mode definition: #{chain_mode}" unless CHAIN_MODE.include?(chain_mode)
          raise ArgumentError, "Invalid os definition: #{os}" unless OS.include?(os)

          unless modules.size == execution_delay.size
            raise ArgumentError, "Number of execution_delay values (#{execution_delay.size}) must be consistent with number of modules (#{modules.size})"
          end
          execution_delay.each { |delay| raise TypeError, "Invalid execution_delay value: #{delay}. Values must be Integers." unless delay.is_a?(Integer) }

          unless modules.size == execution_order.size
            raise ArgumentError, "Number of execution_order values (#{execution_order.size}) must be consistent with number of modules (#{modules.size})"
          end
          execution_order.each { |order| raise TypeError, "Invalid execution_order value: #{order}. Values must be Integers." unless order.is_a?(Integer) }

          # if multiple browsers were specified, check each browser
          if browser.is_a?(Array)
            browser.each do |b|
              raise ArgumentError, "Invalid browser definition: #{browser}" unless BROWSER.include?(b)
            end
          # else, if only one browser was specified, check browser and browser version
          else
            raise ArgumentError, "Invalid browser definition: #{browser}" unless BROWSER.include?(browser)

            if browser_version != 'ALL' && !(VERSION.include?(browser_version[0, 2].gsub(/\s+/, '')) &&
                  BeEF::Filters.is_valid_browserversion?(browser_version[2..-1].gsub(/\s+/, '')) && browser_version.length < MAX_VER_LEN)
              raise ArgumentError, "Invalid browser_version definition: #{browser_version}"
            end
          end

          if os_version != 'ALL' && !(VERSION.include?(os_version[0, 2].gsub(/\s+/, '')) &&
                  BeEF::Filters.is_valid_osversion?(os_version[2..-1].gsub(/\s+/, '')) && os_version.length < MAX_VER_LEN)
            return ArgumentError, "Invalid os_version definition: #{os_version}"
          end

          # check if module names, conditions and options are ok
          modules.each do |cmd_mod|
            mod = BeEF::Core::Models::CommandModule.where(name: cmd_mod['name']).first

            raise "The specified module name (#{cmd_mod['name']}) does not exist" if mod.nil?

            modk = BeEF::Module.get_key_by_database_id(mod.id)
            mod_options = BeEF::Module.get_options(modk)

            opt_count = 0
            mod_options.each do |opt|
              if opt['name'] != cmd_mod['options'].keys[opt_count]
                raise ArgumentError, "The specified option (#{cmd_mod['options'].keys[opt_count]}) for module (#{cmd_mod['name']}) was not specified"
              end

              opt_count += 1
            end
          end

          true
        end
      end
    end
  end
end
