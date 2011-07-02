#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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
