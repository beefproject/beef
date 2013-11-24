#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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
      driver.interface.getcommands.each { |folder|
        folder['children'].each { |command|
          @@commands << folder['text'].gsub(/\s/,"_") + command['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")
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

  @@commands_opts = Rex::Parser::Arguments.new(
    "-h" => [ false, "Help."],
    "-s" => [ false, "<search term>"],
    "-r" => [ false, "List modules which have responses against them only"])
  
  def cmd_commands(*args)

    searchstring = nil
    responly = nil
    
    @@commands_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_commands_help
          return false
        when "-s"
          searchstring = args[1].downcase if not args[1].nil?
        when "-r"
          responly = true
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

        cmdstring = folder['text'].gsub(/\s/,"_") + command['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")

        if not searchstring.nil?
          if not cmdstring.downcase.index(searchstring).nil?
            tbl << [command['id'].to_i,
                cmdstring,
                command['status'].gsub(/^Verified /,""),
                driver.interface.getcommandresponses(command['id']).length] #TODO
          end
        elsif not responly.nil?
             tbl << [command['id'].to_i,
                cmdstring,
                command['status'].gsub(/^Verified /,""),
                driver.interface.getcommandresponses(command['id']).length] if driver.interface.getcommandresponses(command['id']).length.to_i > 0

        else 
         tbl << [command['id'].to_i,
            cmdstring,
            command['status'].gsub(/^Verified /,""),
            driver.interface.getcommandresponses(command['id']).length] #TODO
        end

      }
    }
    
    puts "\n"
    puts "List command modules for this target\n"
    puts tbl.to_s + "\n"
                
  end
  
  def cmd_commands_help(*args)
    print_status("List command modules for this target")
    print_line("Usage: commands [options]")
    print_line
    print @@commands_opts.usage()
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
          if args[0].chomp == x['text'].gsub(/\s/,"_")+y['text'].gsub(/[-\(\)]/,"").gsub(/\W+/,"_")
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
    
    if driver.interface.targetid.length > 1
      driver.update_prompt("(%bld%redMultiple%clr) ["+driver.interface.targetid.join(",")+"] / "+driver.interface.cmd['Name']+" ")
    else
      driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.first.to_s+"] / "+driver.interface.cmd['Name']+" ")
    end

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
