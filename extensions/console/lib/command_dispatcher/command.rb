#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Console
module CommandDispatcher
  
class Command
  include BeEF::Extension::Console::CommandDispatcher

  @@params = []
  
  def initialize(driver)
    super
    begin 
      driver.interface.cmd['Data'].each{|data|
        @@params << data['name']
      }
    rescue
      return
    end
  end
  
  def commands
    {
      "execute"   => "Go! Execute the command module",
      "param"     => "Set parameters for this module",
      "response"  => "Get previous responses to this command module",
      "cmdinfo"   => "See information about this particular command module"
    }
  end
  
  def name
    "Command"
  end
  
  @@bare_opts = Rex::Parser::Arguments.new(
	  "-h" => [ false, "Help."              ])
  
  def cmd_cmdinfo(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_cmdinfo_help
          return false
        end
    }
      
    print_line("Module name: " + driver.interface.cmd['Name'])
    print_line("Module category: " + driver.interface.cmd['Category'].to_s)
    print_line("Module description: " + driver.interface.cmd['Description'])
    print_line("Module parameters:") if not driver.interface.cmd['Data'].length == 0

    driver.interface.cmd['Data'].each{|data|
      if data['type'].eql?("combobox")
        print_line(data['name'] + " => \"" + data['value'].to_s + "\" # " + data['ui_label'] + " (Options include: " + data['store_data'].to_s + ")")
      else
        print_line(data['name'] + " => \"" + data['value'].to_s + "\" # " + data['ui_label'])
      end
    } if not driver.interface.cmd['Data'].nil?
  end
  
  def cmd_cmdinfo_help(*args)
    print_status("Displays information about the current command module")
  end
  
  def cmd_param(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_param_help
          return false
        end
    }
    
    if (args[0] == nil || args[1] == nil)
      cmd_param_help
      return
    else
      p = ""
      (1..args.length-1).each do |x|
        p << args[x] << " "
      end
      p.chop!
      driver.interface.setparam(args[0],p)
    end
  end
  
  def cmd_param_help(*args)
    print_status("Sets parameters for the current modules. Run \"cmdinfo\" to see the parameter values")
    print_status("  Usage: param <paramname> <paramvalue>")
  end

  def cmd_param_tabs(str,words)
    return if words.length > 1

    if @@params == ""
      #nothing prepopulated?
    else
      return @@params
    end
  end
  
  def cmd_execute(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_execute_help
          return false
        end
    }
    
    if driver.interface.executecommand == true
      print_status("Command successfully queued")
    else
      print_status("Something went wrong")
    end
  end
  
  def cmd_execute_help(*args)
    print_status("Execute this module... go on!")
  end
  
  def cmd_response(*args)
    @@bare_opts.parse(args) {|opt, idx, val|
      case opt
        when "-h"
          cmd_response_help
          return false
        end
    }
    
    tbl = Rex::Ui::Text::Table.new(
      'Columns' =>
        [
          'Id',
          'Executed Time',
          'Response Time'
        ])

    if args[0] == nil
      lastcmdid = nil
      driver.interface.getcommandresponses.each do |resp|
        indiresp = driver.interface.getindividualresponse(resp['object_id'])
        respout = ""
        if indiresp.nil? or indiresp[0].nil?
          respout = "No response yet"
        else
          respout = Time.at(indiresp[0]['date'].to_i).to_s
          lastcmdid = resp['object_id']
        end
        tbl << [resp['object_id'].to_s, resp['creationdate'], respout]
      end
    
      puts "\n"
      puts "List of responses for this command module:\n"
      puts tbl.to_s + "\n"

      if not lastcmdid.nil?
        resp = driver.interface.getindividualresponse(lastcmdid)
        puts "\n"
        print_line("The last response [" + lastcmdid.to_s + "] was retrieved: " + Time.at(resp[0]['date'].to_i).to_s)
        print_line("Response:")
        resp.each do |op|
          print_line(op['data']['data'].to_s)
        end
      end
    else
      output = driver.interface.getindividualresponse(args[0])
      if output.nil?
        print_line("Invalid response ID")
      elsif output[0].nil?
        print_line("No response yet from the hooked browser or perhaps an invalid response ID")
      else
        print_line("Results retrieved: " + Time.at(output[0]['date'].to_i).to_s)
        print_line("")
        print_line("Response:")
        output.each do |op|
          print_line(op['data']['data'].to_s)
        end
      end
    end
  end
  
  def cmd_response_help(*args)
    print_status("List and review particular responses to this command")
    print_status("  Usage: response (id)")
    print_status("  If you omit id you'll see a list of all responses for the currently active command module")
  end
  
end

end end end end
