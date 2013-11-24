#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
      "irb"     => "Drops into an interactive Ruby environment",
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
      if driver.interface.targetid.length > 1
        driver.update_prompt("(%bld%redMultiple%clr) ["+driver.interface.targetid.join(",")+"] ")
      else
        driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.first.to_s+"] ")
      end
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
          'Hook Host',
          'Browser',
          'OS',
          'Hardware'
        ])
    
    BeEF::Core::Models::HookedBrowser.all(:lastseen.gte => (Time.new.to_i - 30)).each do |zombie|
      tbl << [zombie.id,zombie.ip,BeEF::Core::Models::BrowserDetails.get(zombie.session,"HostName").to_s,BeEF::Core::Models::BrowserDetails.get(zombie.session, 'BrowserName').to_s+"-"+BeEF::Core::Models::BrowserDetails.get(zombie.session, 'BrowserVersion').to_s,BeEF::Core::Models::BrowserDetails.get(zombie.session, 'OsName'),BeEF::Core::Models::BrowserDetails.get(zombie.session, 'Hardware')]
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
          'Hook Host',
          'Browser',
          'OS',
          'Hardware'
        ])
    
    BeEF::Core::Models::HookedBrowser.all(:lastseen.lt => (Time.new.to_i - 30)).each do |zombie|
      tbl << [zombie.id,zombie.ip,BeEF::Core::Models::BrowserDetails.get(zombie.session,"HostName").to_s,BeEF::Core::Models::BrowserDetails.get(zombie.session, 'BrowserName').to_s+"-"+BeEF::Core::Models::BrowserDetails.get(zombie.session, 'BrowserVersion').to_s,BeEF::Core::Models::BrowserDetails.get(zombie.session, 'OsName'),BeEF::Core::Models::BrowserDetails.get(zombie.session, 'Hardware')]
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

	targets = args[0].split(',')
	targets.each {|t|
        if not onlinezombies.include?(t.to_i)
          print_status("Browser [id:"+t.to_s+"] does not appear to be online.")
          return false
        end
		#print_status("Adding browser [id:"+t.to_s+"] to target list.")
    }
 
    if not driver.interface.settarget(targets).nil?
    
      if (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core')
	      driver.destack_dispatcher
          driver.update_prompt('')
      end

      driver.enstack_dispatcher(Target)
      if driver.interface.targetid.length > 1
        driver.update_prompt("(%bld%redMultiple%clr) ["+driver.interface.targetid.join(",")+"] ")
      else
        driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.first.to_s+"] ")
      end
    end
  end
  
  def cmd_target_help(*args)
    print_status("Target a particular online, hooked browser")
    print_status("  Usage: target <id>")
  end

  def cmd_irb(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_irb_help
          return false
        end
      }

    print_status("Starting IRB shell...\n")

    begin
      Rex::Ui::Text::IrbShell.new(binding).run
    rescue
      print_error("Error during IRB: #{$!}\n\n#{$@.join("\n")}")
    end
  end

  def cmd_irb_help(*args)
    print_status("Load the IRB, Interative Ruby Shell")
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
    
    targets = args[0].split(',')
    targets.each {|t|
        if not offlinezombies.include?(t.to_i)
          print_status("Browser [id:"+t.to_s+"] does not appear to be offline.")
          return false
        end
    #print_status("Adding browser [id:"+t.to_s+"] to target list.")
    }

    # if not offlinezombies.include?(args[0].to_i)
    #   print_status("Browser does not appear to be offline..")
    #   return false
    # end
    
    if not driver.interface.setofflinetarget(targets).nil?
      if (driver.dispatcher_stack.size > 1 and
	      driver.current_dispatcher.name != 'Core')
	      driver.destack_dispatcher
          driver.update_prompt('')
      end
    
      driver.enstack_dispatcher(Target)
      if driver.interface.targetid.length > 1
        driver.update_prompt("(%bld%redMultiple%clr) ["+driver.interface.targetid.join(",")+"] ")
      else
        driver.update_prompt("(%bld%red"+driver.interface.targetip+"%clr) ["+driver.interface.targetid.first.to_s+"] ")
      end
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
          if args[1] == "-s" and not args[2].nil?
           driver.run_single("commands #{args[1]} #{args[2]}")
           return
         else
          driver.run_single("commands")
        end
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
