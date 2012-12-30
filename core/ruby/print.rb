#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Function used to print errors to the console
# @param [String] s String to be printed
def print_error(s)
  puts Time.now.localtime.strftime("[%k:%M:%S]")+'[!]'.red+' '+s
end

# Function used to print information to the console
# @param [String] s String to be printed
def print_info(s)
  puts Time.now.localtime.strftime("[%k:%M:%S]")+'[*]'.blue+' '+s
end

# Function used to print debug information
# @param [String] s String to be printed
# @note This function will only print messages if the debug flag is set to true
def print_debug(s)
  config = BeEF::Core::Configuration.instance
  if config.get('beef.debug') || BeEF::Core::Console::CommandLine.parse[:verbose]
    puts Time.now.localtime.strftime("[%k:%M:%S]")+'[>]'.yellow+' '+s.to_s
  end
end

# Function used to print successes to the console
# @param [String] s String to be printed
def print_success(s)
  puts Time.now.localtime.strftime("[%k:%M:%S]")+'[+]'.green+' '+s
end

# Print multiple lines with decoration split by the return character
# @param [String] s String to be printed
# @note The string passed needs to be separated by the "\n" for multiple lines to be printed
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

# Function used to print over the current line
# @param [String] s String to print over current line
# @note To terminate the print_over functionality your last print_over line must include a "\n" return
def print_over(s)
  time = Time.now.localtime.strftime("[%k:%M:%S]")
  print "\r#{time}"+"[*]".blue+" #{s}"
end
