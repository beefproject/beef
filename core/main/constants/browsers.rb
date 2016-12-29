#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
module Core
module Constants

  module Browsers

    FF      = 'FF'       # Firefox
    M       = 'M'        # Mozilla
    IE      = 'IE'       # Internet Explorer
    S       = 'S'        # Safari
    K       = 'K'        # Konqueror
    C       = 'C'        # Chrome
    O       = 'O'        # Opera
    A       = 'A'        # Avant
    MI      = 'MI'       # Midori
    OD      = 'OD'       # Odyssey
    BR      = 'BR'       # Brave
    ALL     = 'ALL'      # ALL
    UNKNOWN = 'UN'       # Unknown

    FRIENDLY_FF_NAME  = 'Firefox'
    FRIENDLY_M_NAME   = 'Mozilla'
    FRIENDLY_IE_NAME  = 'Internet Explorer'
    FRIENDLY_S_NAME   = 'Safari'
    FRIENDLY_K_NAME   = 'Konqueror'
    FRIENDLY_C_NAME   = 'Chrome'
    FRIENDLY_O_NAME   = 'Opera'
    FRIENDLY_A_NAME   = 'Avant'
    FRIENDLY_MI_NAME  = 'Midori'
    FRIENDLY_OD_NAME  = 'Odyssey'
    FRIENDLY_BR_NAME  = 'Brave'
    FRIENDLY_UN_NAME  = 'UNKNOWN'

    # Attempt to retrieve a browser's friendly name
    # @param [String] browser_name Short browser name
    # @return [String] Friendly browser name
    def self.friendly_name(browser_name)

      case browser_name
        when FF;       return FRIENDLY_FF_NAME
        when M ;       return FRIENDLY_M_NAME
        when IE;       return FRIENDLY_IE_NAME
        when S ;       return FRIENDLY_S_NAME
        when K ;       return FRIENDLY_K_NAME
        when C ;       return FRIENDLY_C_NAME
        when O ;       return FRIENDLY_O_NAME
        when A ;       return FRIENDLY_A_NAME
        when MI ;      return FRIENDLY_MI_NAME
        when OD ;      return FRIENDLY_OD_NAME
        when BR ;      return FRIENDLY_BR_NAME
        when UNKNOWN;  return FRIENDLY_UN_NAME
      end

    end

  end

end
end
end
