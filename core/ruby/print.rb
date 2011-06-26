#
# Function used to print errors to the console
#
def print_error(s)
  puts Time.now.localtime.strftime("[%k:%M:%S]")+'[!]'.red+' '+s
end

#
# Function used to print information to the console
#
def print_info(s)
  puts Time.now.localtime.strftime("[%k:%M:%S]")+'[*]'.blue+' '+s
end

#
# Function used to print debug information
#
def print_debug(s)
    config = BeEF::Core::Configuration.instance
    if config.get('beef.debug') || (BeEF::Extension.is_loaded('console') && BeEF::Extension::Console.verbose?)
        puts Time.now.localtime.strftime("[%k:%M:%S]")+'[>]'.yellow+' '+s.to_s
    end
end

#
# Function used to print successes to the console
#
def print_success(s)
  puts Time.now.localtime.strftime("[%k:%M:%S]")+'[+]'.green+' '+s
end

#
# Produces something that looks like that:
#
# [12:16:32]    |   Hook URL: http://127.0.0.1:3000/hook.js
# [12:16:32]    |   UI URL:   http://127.0.0.1:3000/ui/panel
# [12:16:32]    |_  Demo URL: http://127.0.0.1:3000/demos/basic.html
#
# The Template is like this:
#
# [date]   |   content
#
def print_more(s)
  time = Time.now.localtime.strftime("[%k:%M:%S]")
  lines = s.split("\n")
  
  lines.each_with_index do |line, index| 
    if ((index+1) == lines.size)
      puts "#{time}    |_  #{line}"
    else
      puts "#{time}    |   #{line}"
    end
  end 
end
