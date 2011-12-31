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

class Core
  include BeEF::Extension::Console::CommandDispatcher
  
  def initialize(driver)
    super
  end
  
  def commands
    {
      "?"       => "Help menu",
      "back"    => "Move back from the current context",
      "exit"    => "Exit the console",
      "help"    => "Help menu",
      "jobs"    => "Print jobs",
      "online"  => "List online hooked browsers",
      "offline" => "List previously hooked browsers",
      "quit"    => "Exit the console",
      "review"  => "Target a particular previously hooked (offline) hooked browser",
      "show"    => "Displays 'zombies' or 'browsers' or 'commands'. (For those who prefer the MSF way)",
      "target"  => "Target a particular online hooked browser",
    }
  end
  
  def name
    "Core"
  end
  
  def cmd_back(*args)
	  if (driver.current_dispatcher.name == 'Command')
	    driver.remove_dispatcher('Command')
	    driver.interface.clearcommand #TODO: TIDY THIS UP
	    driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.to_s+"] ")
    elsif (driver.current_dispatcher.name == 'Target')
      driver.remove_dispatcher('Target')
      driver.interface.cleartarget
      driver.update_prompt('')
	  elsif (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core')
	      
	      driver.destack_dispatcher
	      
	      driver.update_prompt('')
    end
  end
  
  def cmd_back_help(*args)
    print_status("Move back one step")
  end
  
  def cmd_exit(* args)
    driver.stop
  end
  
  alias cmd_quit cmd_exit
  
  @@jobs_opts = Rex::Parser::Arguments.new(
	  "-h" => [ false, "Help."              ],
	  "-l" => [ false, "List jobs."         ],
	  "-k" => [ true, "Terminate the job."  ])
	  
	def cmd_jobs(*args)
    if (args[0] == nil)
      cmd_jobs_list
      print_line "Try: jobs -h"
      return
    end

    @@jobs_opts.parse(args) {|opt, idx, val|
      case opt
        when "-k"
          if (not driver.jobs.has_key?(val))
            print_error("no such job")
          else
            #This is a special job, that has to be terminated different prior to cleanup
            if driver.jobs[val].name == "http_hook_server"
              print_line("Nah uh uh - can't stop this job ya BeEF head!")
            else
              print_line("Stopping job: #{val}...")
              driver.jobs.stop_job(val)
            end
          end
        when "-l"
          cmd_jobs_list
        when "-h"
          cmd_jobs_help
          return false
        end
      }
  end

  def cmd_jobs_help(*args)
    print_line "Usage: jobs [options]"
    print_line
    print @@jobs_opts.usage()
  end

  def cmd_jobs_list
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Id',
          'Job Name'
        ])
    driver.jobs.keys.each{|k|
      tbl << [driver.jobs[k].jid.to_s, driver.jobs[k].name]
    }
    puts "\n"
    puts tbl.to_s + "\n"
  end
  
  @@bare_opts = Rex::Parser::Arguments.new(
	  "-h" => [ false, "Help."              ])
  
  def cmd_online(*args)
    
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_online_help
          return false
        end
    }
    
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Id',
          'IP',
          'OS'
        ])
    
    BeEF::Core::Models::HookedBrowser.all(:lastseen.gte => (Time.new.to_i - 30)).each do |zombie|
      tbl << [zombie.id,zombie.ip,beef_logo_to_os(BeEF::Extension::Initialization::Models::BrowserDetails.os_icon(zombie.session))]
    end
    
    puts "\n"
    puts "Currently hooked browsers within BeEF"
    puts "\n"
    puts tbl.to_s + "\n"    
  end
  
  def cmd_online_help(*args)
    print_status("Show currently hooked browsers within BeEF")
  end
  
  def cmd_offline(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_offline_help
          return false
        end
    }
    
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Id',
          'IP',
          'OS'
        ])
    
    BeEF::Core::Models::HookedBrowser.all(:lastseen.lt => (Time.new.to_i - 30)).each do |zombie|
      tbl << [zombie.id,zombie.ip,beef_logo_to_os(BeEF::Extension::Initialization::Models::BrowserDetails.os_icon(zombie.session))]
    end
    
    puts "\n"
    puts "Previously hooked browsers within BeEF"
    puts "\n"
    puts tbl.to_s + "\n"
  end
  
  def cmd_offline_help(*args)
    print_status("Show previously hooked browsers")
  end
  
  def cmd_target(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_target_help
          return false
        end
    }
    
    if args[0] == nil
      cmd_target_help
      return
    end
    
    onlinezombies = []
    BeEF::Core::Models::HookedBrowser.all(:lastseen.gt => (Time.new.to_i - 30)).each do |zombie|
      onlinezombies << zombie.id
    end
    
    if not onlinezombies.include?(args[0].to_i)
      print_status("Browser does not appear to be online..")
      return false
    end
    
    if not driver.interface.settarget(args[0]).nil?
    
      if (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core')

	      driver.destack_dispatcher
        driver.update_prompt('')
      end
    
      driver.enstack_dispatcher(Target)
      driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.to_s+"] ")
    end
  end
  
  def cmd_target_help(*args)
    print_status("Target a particular online, hooked browser")
    print_status("  Usage: target <id>")
  end
  
  def cmd_review(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_review_help
          return false
        end
    }
    
    if args[0] == nil
      cmd_review_help
      return
    end
    
    offlinezombies = []
    BeEF::Core::Models::HookedBrowser.all(:lastseen.lt => (Time.new.to_i - 30)).each do |zombie|
      offlinezombies << zombie.id
    end
    
    if not offlinezombies.include?(args[0].to_i)
      print_status("Browser does not appear to be offline..")
      return false
    end
    
    if not driver.interface.setofflinetarget(args[0]).nil?
      if (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core')

	      driver.destack_dispatcher
        driver.update_prompt('')
      end
    
      driver.enstack_dispatcher(Target)
      driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.to_s+"] ")
    end  
    
  end
  
  def cmd_review_help(*args)
    print_status("Review an offline, previously hooked browser")
    print_status("  Usage: review <id>")
  end
  
  def cmd_show(*args)
    args << "-h" if (args.length == 0)
    
    args.each { |type|
      case type
      when '-h'
        cmd_show_help
      when 'zombies'
        driver.run_single("online")
      when 'browsers'
        driver.run_single("online")
      when 'online'
        driver.run_single("online")
      when 'offline'
        driver.run_single("offline")
      when 'commands'
        if driver.dispatched_enstacked(Target)
          driver.run_single("commands")
        else
          print_error("You aren't targeting a zombie yet")
        end
      when 'info'
        if driver.dispatched_enstacked(Target)
          driver.run_single("info")
        else
          print_error("You aren't targeting a zombie yet")
        end
      when 'cmdinfo'
        if driver.dispatched_enstacked(Command)
          driver.run_single("cmdinfo")
        else
          print_error("You haven't selected a command module yet")
        end
      else
        print_error("Invalid parameter, try show -h for more information.")
      end
    }
  end
  
  def cmd_show_tabs(str, words)
    return [] if words.length > 1
    
    res = %w{zombies browsers online offline}    
    
    if driver.dispatched_enstacked(Target)
      res.concat(%w{commands info})
    end
    
    if driver.dispatched_enstacked(Command)
      res.concat(%w{cmdinfo})
    end
    
    return res
  end
  
  def cmd_show_help
    global_opts = %w{zombies browsers}
    print_status("Valid parameters for the \"show\" command are: #{global_opts.join(", ")}")
    
    target_opts = %w{commands}
    print_status("If you're targeting a module, you can also specify: #{target_opts.join(", ")}")
  end
  
  def beef_logo_to_os(logo)
	  case logo
    when "mac.png"
      hbos = "Mac OS X"
    when "linux.png"
      hbos = "Linux"
    when "win.png"
      hbos = "Microsoft Windows"
    when "unknown.png"
      hbos = "Unknown"
    end
  end
  
end

end end end end