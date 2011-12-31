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

module BeEF
module Core
module Constants
  
  module Browsers

   	FF      = 'FF'       # Firefox
   	M       = 'M'        # Mozila
   	IE      = 'IE'       # Internet Explorer
   	S       = 'S'        # Safari
   	K       = 'K'        # Konqueror
   	C       = 'C'        # Chrome
    O       = 'O'        # Opera
   	ALL     = 'ALL'      # ALL
   	UNKNOWN = 'UN'       # Unknown
	
   	FRIENDLY_FF_NAME  = 'Firefox' 
   	FRIENDLY_M_NAME   = 'Mozila'
   	FRIENDLY_IE_NAME  = 'Internet Explorer'
   	FRIENDLY_S_NAME   = 'Safari'
   	FRIENDLY_K_NAME   = 'Konqueror'
   	FRIENDLY_C_NAME   = 'Chrome'
    FRIENDLY_O_NAME   = 'Opera'
   	FRIENDLY_UN_NAME  = "UNKNOWN"
 
    # Attempt to retrieve a browsers friendly name
    # @param [String] browser_name Short browser name
    # @return [String] Friendly browser name
   	def self.friendly_name(browser_name)
	  
   	  case browser_name
   	    when FF;       return FRIENDLY_FF_NAME 
   	    when M;        return FRIENDLY_M_NAME 	   
   	    when IE;       return FRIENDLY_IE_NAME   	   
   	    when S;        return FRIENDLY_S_NAME  	   
   	    when K;        return FRIENDLY_K_NAME  	   
        when C;        return FRIENDLY_C_NAME
        when O;        return FRIENDLY_O_NAME
        when UNKNOWN;  return FRIENDLY_UN_NAME
   	  end
	    
  	end

    # Attempt to match the browserstring to a browser constant
    # @param [String] browserstring Browser UA string
    # @return [Array] An array of matching browser constants
    # @todo Confirm this function returns an array if multiple constants are matched
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
         when /Opera/
				    matches << O
				end
			end
			matches.uniq
	  end

  end
  
end
end
end
