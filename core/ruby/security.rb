#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# @note Prevent exec from ever being used
def exec(args)
  puts "For security reasons the exec method is not accepted in the Browser Exploitation Framework code base."
  exit
end

# @note Prevent system from ever being used
def system(args)
  puts "For security reasons the system method is not accepted in the Browser Exploitation Framework code base."
  exit
end

# @note Prevent Kernel.system from ever being used
def Kernel.system(args)
  puts "For security reasons the Kernel.system method is not accepted in the Browser Exploitation Framework code base."
  exit
end

