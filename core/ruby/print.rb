#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Function used to print errors to the console
# @param [String] s String to be printed
def print_error(s)
  puts Time.now.localtime.strftime('[%k:%M:%S]') + '[!]' + ' ' + s.to_s
  BeEF.logger.error s.to_s
end

# Function used to print information to the console
# @param [String] s String to be printed
def print_info(s)
  puts Time.now.localtime.strftime('[%k:%M:%S]') + '[*]' + ' ' + s.to_s
  BeEF.logger.info s.to_s
end

# Function used to print information to the console (wraps print_info)
# @param [String] s String to be printed
def print_status(s)
  print_info(s)
end

# Function used to print warning information
# @param [String] s String to be printed
def print_warning(s)
  puts Time.now.localtime.strftime('[%k:%M:%S]') + '[!]' + ' ' + s.to_s
  BeEF.logger.warn s.to_s
end

# Function used to print debug information
# @param [String] s String to be printed
# @note This function will only print messages if the debug flag is set to true
def print_debug(s)
  config = BeEF::Core::Configuration.instance
  return unless config.get('beef.debug') || BeEF::Core::Console::CommandLine.parse[:verbose]

  puts Time.now.localtime.strftime('[%k:%M:%S]') + '[>]' + ' ' + s.to_s
  BeEF.logger.debug s.to_s
end

# Function used to print successes to the console
# @param [String] s String to be printed
def print_success(s)
  puts Time.now.localtime.strftime('[%k:%M:%S]') + '[+]' + ' ' + s.to_s
  BeEF.logger.info s.to_s
end

# Function used to print successes to the console (wraps print_success)
# @param [String] s String to be printed
def print_good(s)
  print_success(s)
end

# Print multiple lines with decoration split by the return character
# @param [String] s String to be printed
# @note The string passed needs to be separated by the "\n" for multiple lines to be printed
def print_more(s)
  time = Time.now.localtime.strftime('[%k:%M:%S]')

  lines = if s.instance_of?(Array)
            s
          else
            s.split("\n")
          end

  lines.each_with_index do |line, index|
    if (index + 1) == lines.size
      puts "#{time}    |_  #{line}"
      BeEF.logger.info "#{time}    |_  #{line}"
    else
      puts "#{time}    |   #{line}"
      BeEF.logger.info "#{time}    |   #{line}"
    end
  end
end

# Function used to print over the current line
# @param [String] s String to print over current line
# @note To terminate the print_over functionality your last print_over line must include a "\n" return
def print_over(s)
  time = Time.now.localtime.strftime('[%k:%M:%S]')
  print "\r#{time}" + '[*]'.blue + " #{s}"
  BeEF.logger.info s.to_s
end
