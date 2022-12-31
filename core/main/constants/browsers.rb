#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
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
        E       = 'E'        # Microsoft Edge
        S       = 'S'        # Safari
        EP      = 'EP'       # Epiphany
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
        FRIENDLY_E_NAME   = 'MSEdge'
        FRIENDLY_S_NAME   = 'Safari'
        FRIENDLY_EP_NAME  = 'Epiphany'
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
          when FF then FRIENDLY_FF_NAME
          when M then FRIENDLY_M_NAME
          when IE then FRIENDLY_IE_NAME
          when E then       FRIENDLY_E_NAME
          when S then       FRIENDLY_S_NAME
          when EP then FRIENDLY_EP_NAME
          when K then       FRIENDLY_K_NAME
          when C then       FRIENDLY_C_NAME
          when O then       FRIENDLY_O_NAME
          when A then       FRIENDLY_A_NAME
          when MI then      FRIENDLY_MI_NAME
          when OD then      FRIENDLY_OD_NAME
          when BR then      FRIENDLY_BR_NAME
          when UNKNOWN then FRIENDLY_UN_NAME
          end
        end
      end
    end
  end
end
