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