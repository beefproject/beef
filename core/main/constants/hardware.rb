#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
module Core
module Constants
  
  # @note The hardware's strings for hardware detection.
  module Hardware

    HW_UNKNOWN_IMG        = 'pc.png'
	HW_VM_IMG             = 'vm.png'
	HW_LAPTOP_IMG         = 'laptop.png'
	HW_IPHONE_UA_STR      = 'iPhone'
 	HW_IPHONE_IMG         = 'iphone.jpg'
	HW_IPAD_UA_STR	      = 'iPad'
	HW_IPAD_IMG	          = 'ipad.png'
	HW_IPOD_UA_STR	      = 'iPod'
	HW_IPOD_IMG	          = 'ipod.jpg'
	HW_BLACKBERRY_UA_STR  = 'BlackBerry'
	HW_BLACKBERRY_IMG     = 'blackberry.png'
	HW_WINPHONE_UA_STR    = 'Windows Phone'
	HW_WINPHONE_IMG       = 'win.png'
    HW_ZUNE_UA_STR        = 'ZuneWP7'
    HW_ZUNE_IMG           = 'zune.gif'
	HW_KINDLE_UA_STR      = 'Kindle'
	HW_KINDLE_IMG         = 'kindle.png'
	HW_NOKIA_UA_STR       = 'Nokia'
	HW_NOKIA_IMG          = 'nokia.ico'
	HW_HTC_UA_STR         = 'HTC'
	HW_HTC_IMG            = 'htc.ico'
	HW_MOTOROLA_UA_STR    = 'motorola'
	HW_MOTOROLA_IMG       = 'motorola.png'
	HW_GOOGLE_UA_STR      = 'Nexus One'
	HE_GOOGLE_IM          = 'nexus.png'
	HW_ERICSSON_UA_STR    = 'Ericsson'
	HW_ERICSSON_IMG       = 'sony_ericsson.png'
	HW_ALL_UA_STR         = 'All'

        # Attempt to match operating system string to constant
        # @param [String] name Name of operating system
        # @return [String] Constant name of matched operating system, returns 'ALL'  if nothing are matched
		def self.match_hardware(name)
			case name.downcase
				when /iphone/
					HW_IPHONE_UA_STR
				when /ipad/
					HW_IPAD_UA_STR
				when /ipod/
					HW_IPOD_UA_STR
				when /blackberry/
					HW_BLACKBERRY_UA_STR
				when /windows phone/
					HW_WINPHONE_UA_STR
				when /zune/
					HW_ZUNE_UA_STR
				when /kindle/
					HW_KINDLE_UA_STR
				when /nokia/
					HW_NOKIA_UA_STR
				when /motorola/
					HW_MOTOROLA_UA_STR
				when /htc/
					HW_HTC_UA_STR
				when /google/
					HW_GOOGLE_UA_STR
				when /ericsson/
					HW_ERICSSON_UA_STR
				else
					'ALL'
				end
		end
	
  end
  
end
end
end
