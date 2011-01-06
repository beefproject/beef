module BeEF
  
#
# This module list all the constants used by the framework.
# 
module Constants

  module CommandModule

    MODULE_TARGET_VERIFIED_NOT_WORKING =  0
    MODULE_TARGET_VERIFIED_WORKING =      1
    MODULE_TARGET_VERIFIED_USER_NOTIFY =  2
    MODULE_TARGET_VERIFIED_UNKNOWN =      3
    
    MODULE_TARGET_VERIFIED_NOT_WORKING_IMG = 'red.png'
    MODULE_TARGET_VERIFIED_USER_NOTIFY_IMG = 'orange.png'
    MODULE_TARGET_VERIFIED_WORKING_IMG =     'green.png'
    MODULE_TARGET_VERIFIED_UNKNOWN_IMG =     'grey.png'
    
    MODULE_TARGET_IMG_PATH = 'public/images/icons/'

  end

  module Browsers

  	FF      = 'FF'       # Firefox
  	M       = 'M'        # Mozila
  	IE      = 'IE'       # Internet Explorer
  	S       = 'S'        # Safari
  	K       = 'K'        # Konqueror
  	C       = 'C'        # Chrome
  	ALL     = 'ALL'      # ALL
  	UNKNOWN = 'UNKNOWN'  # Unknown
  	
  	FRIENDLY_FF_NAME  = 'Firefox' 
  	FRIENDLY_M_NAME   = 'Mozila'
  	FRIENDLY_IE_NAME  = 'Internet Explorer'
  	FRIENDLY_S_NAME   = 'Safari'
  	FRIENDLY_K_NAME   = 'Konqueror'
  	FRIENDLY_C_NAME   = 'Chrome'  	
  	
  	def self.friendly_name(browser_name)
  	  
  	  case browser_name
  	  when FF; return FRIENDLY_FF_NAME 
  	  when M;  return FRIENDLY_M_NAME 	   
  	  when IE; return FRIENDLY_IE_NAME   	   
  	  when S; return  FRIENDLY_S_NAME  	   
  	  when K; return  FRIENDLY_K_NAME  	   
  	  when C; return  FRIENDLY_C_NAME   	   
  	  end
  	  
	  end

		def self.match_browser(browserstring)
				matches = []
				browserstring.split(" ").each do |chunk|
				  case chunk
				    when /Firefox/ , /FF/
					    matches << FF
				    when /Mozilla/
					    matches << M
					  when /Internet Explorer/, /IE/
						  matches << IE
					  when /Safari/
				      matches << S
					  when /Konqueror/
					    matches << K
					  when /Chrome/
					    matches << C
					end
				end
				matches.uniq
		end

  end
  
  # The User Agent strings for browser detection
  module Agents
    
    AGENT_UNKNOWN_IMG     = 'unknown.png'
  	AGENT_FIREFOX_UA_STR  = 'Firefox'
  	AGENT_FIREFOX_IMG     = 'firefox.png'
  	AGENT_MOZILLA_UA_STR  = 'Mozilla'
  	AGENT_MOZILLA_IMG     = 'mozilla.png'
  	AGENT_IE_UA_STR       = 'MSIE'
  	AGENT_IE_IMG          = 'msie.png'
  	AGENT_SAFARI_UA_STR   = 'Safari'
  	AGENT_SAFARI_IMG      = 'safari.png'
  	AGENT_KONQ_UA_STR     = 'Konqueror'
  	AGENT_KONQ_IMG        = 'konqueror.png'
  	AGENT_CHROME_UA_STR   = 'Chrome'
  	AGENT_CHROME_IMG      = 'chrome.png'
    
  end
  
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
  
  # The distributed engine codes
  module DistributedEngine
    
    REQUESTER     = 1
    PORTSCANNER   = 2
    
  end
  
end
end
