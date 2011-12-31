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

