#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
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

        BROWSER = ['FF','C','IE','S','O','ALL']
        OS = ['Linux','Windows','OSX','Android','iOS','BlackBerry','ALL']
        VERSION = ['<','<=','==','>=','>','ALL','Vista','XP']
        CHAIN_MODE = ['sequential','nested-forward']
        MAX_VER_LEN = 25
        # Parse a JSON ARE file and returns an Hash with the value mappings
        def parse(name,author,browser, browser_version, os, os_version, modules, exec_order, exec_delay, chain_mode)
          begin
            success = [true]

            return [false, 'Illegal chain_mode definition'] unless CHAIN_MODE.include?(chain_mode)
            return [false, 'Illegal rule name'] unless BeEF::Filters.is_non_empty_string?(name)
            return [false, 'Illegal author name'] unless BeEF::Filters.is_non_empty_string?(author)

            return [false, 'Illegal browser definition'] unless BROWSER.include?(browser)
            return [false, 'Illegal browser_version definition'] unless
                (VERSION.include?(browser_version[0,2].gsub(/\s+/,'')) || browser_version == 'ALL') &&
                    BeEF::Filters::is_valid_browserversion?(browser_version.split(' ').last) && browser_version.length < MAX_VER_LEN

            return [false, 'Illegal os definition'] unless OS.include?(os)
            return [false, 'Illegal os_version definition'] unless
                 (VERSION.include?(os_version[0, 2].gsub(/\s+/, '')) || os_version == 'ALL') &&
                     BeEF::Filters::is_valid_osversion?(os_version.split(' ').last) && os_version.length < MAX_VER_LEN


            # check if module names, conditions and options are ok
            modules.each do |cmd_mod|
              mod = BeEF::Core::Models::CommandModule.first(:name => cmd_mod['name'])
              if mod != nil
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
              else
                return [false, "The specified module name (#{cmd_mod['name']}) does not exist"]
              end
            end

            exec_order.each{ |order| return [false, 'execution_order values must be Integers'] unless order.integer?}
            exec_delay.each{ |delay| return [false, 'execution_delay values must be Integers'] unless delay.integer?}

            success
          rescue => e
            print_error "#{e.message}"
            print_debug "#{e.backtrace.join("\n")}"
            return [false, 'Something went wrong.']
          end
        end
      end
    end
  end
end
