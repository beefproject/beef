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
module BeEF
module Core
module Constants
  
  # The OS'es strings for os detection.
  module Os
  
    OS_UNKNOWN_IMG        = 'unknown.png'
  	OS_WINDOWS_UA_STR     = 'Windows'
  	OS_WINDOWS_IMG        = 'win.png'
  	OS_LINUX_UA_STR       = 'Linux'
  	OS_LINUX_IMG          = 'linux.png'
  	OS_MAC_UA_STR         = 'Mac'
  	OS_MAC_IMG            = 'mac.png'
	OS_IPHONE_UA_STR      = 'iPhone'
 	OS_IPHONE_IMG         = 'iphone.png'
    OS_ALL_UA_STR         = 'All'

		def self.match_os(name)
			case name.downcase
				when /win/
					OS_WINDOWS_UA_STR
				when /lin/
					OS_LINUX_UA_STR
				when /os x/, /osx/, /mac/
					OS_MAC_UA_STR
				when /iphone/
					OS_IPHONE_UA_STR
				else
					'ALL'
				end
		end
	
  end
  
end
end
end
