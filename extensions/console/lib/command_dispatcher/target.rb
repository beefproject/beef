#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Console
      module CommandDispatcher
        class Target
          include BeEF::Extension::Console::CommandDispatcher

          @@commands = []

          def initialize(driver)
            super
            begin
              driver.interface.getcommands.each do |folder|
                folder['children'].each do |command|
                  @@commands << (folder['text'].gsub(/\s/, '_') + command['text'].gsub(/[-()]/, '').gsub(/\W+/, '_'))
                end
              end
            rescue StandardError
              nil
            end
          end

          def commands
            {
              'commands' => 'List available commands against this particular target',
              'info' => 'Info about the target',
              'select' => 'Prepare the command module for execution against this target',
              'hosts' => 'List identified network hosts',
              'services' => 'List identified network services'
            }
          end

          def name
            'Target'
          end

          @@bare_opts = Rex::Parser::Arguments.new(
            '-h' => [false, 'Help.']
          )

          @@commands_opts = Rex::Parser::Arguments.new(
            '-h' => [false, 'Help.'],
            '-s' => [false, '<search term>'],
            '-r' => [false, 'List modules which have responses against them only']
          )

          def cmd_commands(*args)
            searchstring = nil
            responly = nil

            @@commands_opts.parse(args) do |opt, _idx, _val|
              case opt
              when '-h'
                cmd_commands_help
                return false
              when '-s'
                searchstring = args[1].downcase unless args[1].nil?
              when '-r'
                responly = true
              end
            end

            tbl = Rex::Ui::Text::Table.new(
              'Columns' =>
                [
                  'Id',
                  'Command',
                  'Status',
                  'Execute Count'
                ]
            )

            driver.interface.getcommands.each do |folder|
              folder['children'].each do |command|
                cmdstring = folder['text'].gsub(/\s/, '_') + command['text'].gsub(/[-()]/, '').gsub(/\W+/, '_')

                if !searchstring.nil?
                  unless cmdstring.downcase.index(searchstring).nil?
                    tbl << [command['id'].to_i,
                            cmdstring,
                            command['status'].gsub(/^Verified /, ''),
                            driver.interface.getcommandresponses(command['id']).length] # TODO
                  end
                elsif !responly.nil?
                  if driver.interface.getcommandresponses(command['id']).length.to_i > 0
                    tbl << [command['id'].to_i,
                            cmdstring,
                            command['status'].gsub(/^Verified /, ''),
                            driver.interface.getcommandresponses(command['id']).length]
                  end

                else
                  tbl << [command['id'].to_i,
                          cmdstring,
                          command['status'].gsub(/^Verified /, ''),
                          driver.interface.getcommandresponses(command['id']).length] # TODO
                end
              end
            end

            puts "\n"
            puts "List command modules for this target\n"
            puts tbl.to_s + "\n"
          end

          def cmd_commands_help(*_args)
            print_status('List command modules for this target')
            print_line('Usage: commands [options]')
            print_line
            print @@commands_opts.usage
          end

          def cmd_info(*args)
            @@bare_opts.parse(args) do |opt, _idx, _val|
              case opt
              when '-h'
                cmd_info_help
                return false
              end
            end

            tbl = Rex::Ui::Text::Table.new(
              'Columns' =>
                %w[
                  Param
                  Value
                ]
            )

            driver.interface.select_zombie_summary['results'].each do |x|
              x['data'].each do |k, v|
                tbl << [k, v]
              end
            end

            puts "\nHooked Browser Info:\n"
            puts tbl.to_s + "\n"
          end

          def cmd_info_help(*_args)
            print_status('Display initialisation information about the hooked browser.')
          end

          def cmd_hosts(*args)
            @@bare_opts.parse(args) do |opt, _idx, _val|
              case opt
              when '-h'
                cmd_hosts_help
                return false
              end
            end

            configuration = BeEF::Core::Configuration.instance
            unless configuration.get('beef.extension.network.enable')
              print_error('Network extension is disabled')
              return
            end

            tbl = Rex::Ui::Text::Table.new(
              'Columns' =>
                [
                  'IP',
                  'Hostname',
                  'Type',
                  'Operating System',
                  'MAC Address',
                  'Last Seen'
                ]
            )

            driver.interface.select_network_hosts['results'].each do |x|
              tbl << [x['ip'], x['hostname'], x['type'], x['os'], x['mac'], x['lastseen']]
            end

            puts "\nNetwork Hosts:\n\n"
            puts tbl.to_s + "\n"
          end

          def cmd_hosts_help(*_args)
            print_status("Display information about network hosts on the hooked browser's network.")
          end

          def cmd_services(*args)
            @@bare_opts.parse(args) do |opt, _idx, _val|
              case opt
              when '-h'
                cmd_services_help
                return false
              end
            end

            configuration = BeEF::Core::Configuration.instance
            unless configuration.get('beef.extension.network.enable')
              print_error('Network extension is disabled')
              return
            end

            tbl = Rex::Ui::Text::Table.new(
              'Columns' =>
                %w[
                  IP
                  Port
                  Protocol
                  Type
                ]
            )

            driver.interface.select_network_services['results'].each do |x|
              tbl << [x['ip'], x['port'], x['proto'], x['type']]
            end

            puts "\nNetwork Services:\n\n"
            puts tbl.to_s + "\n"
          end

          def cmd_services_help(*_args)
            print_status("Display information about network services on the hooked browser's network.")
          end

          def cmd_select(*args)
            @@bare_opts.parse(args) do |opt, _idx, _val|
              case opt
              when '-h'
                cmd_select_help
                return false
              end
            end

            if args[0].nil?
              cmd_select_help
              return false
            end

            modid = nil

            if args[0] =~ /[0-9]+/
              modid = args[0]
            else
              driver.interface.getcommands.each do |x|
                x['children'].each do |y|
                  modid = y['id'] if args[0].chomp == x['text'].gsub(/\s/, '_') + y['text'].gsub(/[-()]/, '').gsub(/\W+/, '_')
                end
              end
            end

            if modid.nil?
              print_status('Could not find command module')
              return false
            end

            driver.interface.setcommand(modid)

            driver.enstack_dispatcher(Command) if driver.dispatched_enstacked(Command) == false

            if driver.interface.targetid.length > 1
              driver.update_prompt('(%bld%redMultiple%clr) [' + driver.interface.targetid.join(',') + '] / ' + driver.interface.cmd['Name'] + ' ')
            else
              driver.update_prompt('(%bld%red' + driver.interface.targetip + '%clr) [' + driver.interface.targetid.first.to_s + '] / ' + driver.interface.cmd['Name'] + ' ')
            end
          end

          def cmd_select_help(*_args)
            print_status('Select a command module to use against the current target')
            print_status('  Usage: module <id> OR <modulename>')
          end

          def cmd_select_tabs(_str, words)
            return if words.length > 1

            if @@commands == ''
              # nothing prepopulated?
            else
              @@commands
            end
          end
        end
      end
    end
  end
end
