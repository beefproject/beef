#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
      driver.interface.getcommands.each { |folder|
        folder['children'].each { |command|
          @@commands << folder['text'] + "/" + command['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")
        }
      }
    rescue
      return
    end
  end
  
  def commands
    {
      "commands" => "List available commands against this particular target",
      "info" => "Info about the target",
      "select" => "Prepare the command module for execution against this target"
    }
  end
  
  def name
    "Target"
  end
  
  @@bare_opts = Rex::Parser::Arguments.new(
	  "-h" => [ false, "Help."              ])
  
  def cmd_commands(*args)
    
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_commands_help
          return false
        end
    }
    
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Id',
          'Command',
          'Status',
          'Execute Count'
        ])
    
    
    driver.interface.getcommands.each { |folder|
      folder['children'].each { |command|
        tbl << [command['id'].to_s,
                folder['text'] + "/" + command['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_"),
                command['status'].gsub(/^Verified /,""),
                driver.interface.getcommandresponses(command['id']).length] #TODO
      }
    }
    
    puts "\n"
    puts "List command modules for this target\n"
    puts tbl.to_s + "\n"
                
  end
  
  def cmd_commands_help(*args)
    print_status("List command modules for this target")
  end
  
  def cmd_info(*args)
    
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_info_help
          return false
        end
    }
    
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Param',
          'Value'
        ])
    
    driver.interface.select_zombie_summary['results'].each { |x|
      x['data'].each { |k,v|
        tbl << [k,v]
      }
    }
    
    puts "\nHooked Browser Info:\n"
    puts tbl.to_s + "\n"    
    
  end
  
  def cmd_info_help(*args)
    print_status("Display initialisation information about the hooked browser.")
  end
  
  def cmd_select(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_select_help
          return false
        end
    }
    
    if args[0] == nil
      cmd_select_help
      return false
    end
    
    modid = nil
    
    if args[0] =~ /[0-9]+/
      modid = args[0]
    else
      driver.interface.getcommands.each { |x|
        x['children'].each { |y|
          if args[0].chomp == x['text']+"/"+y['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")
            modid = y['id']
          end
        }
      }
    end
    
    if modid.nil?
      print_status("Could not find command module")
      return false
    end
    
    driver.interface.setcommand(modid)
    
    driver.enstack_dispatcher(Command) if driver.dispatched_enstacked(Command) == false
    
    driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.to_s+"] / "+driver.interface.cmd['Name']+" ")
  end
  
  def cmd_select_help(*args)
    print_status("Select a command module to use against the current target")
    print_status("  Usage: module <id> OR <modulename>")
  end
  
  def cmd_select_tabs(str,words)
    return if words.length > 1
    
    if @@commands == ""
      #nothing prepopulated?
    else
      return @@commands
    end
  end
  
end
  
end end end end
