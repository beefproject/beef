#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Constants

      # @note The OS'es strings for os detection.
      module Os

        OS_UNKNOWN_IMG = 'unknown.png'
        OS_WINDOWS_UA_STR = 'Windows'
        OS_WINDOWS_IMG = 'win.png'
        OS_LINUX_UA_STR = 'Linux'
        OS_LINUX_IMG = 'linux.png'
        OS_MAC_UA_STR = 'Mac'
        OS_MAC_IMG = 'mac.png'
        OS_QNX_UA_STR = 'QNX'
        OS_QNX_IMG = 'qnx.ico'
        OS_BEOS_UA_STR = 'BeOS'
        OS_BEOS_IMG = 'beos.png'
        OS_OPENBSD_UA_STR = 'OpenBSD'
        OS_OPENBSD_IMG = 'openbsd.ico'
        OS_IOS_UA_STR = 'iOS'
        OS_IOS_IMG = 'ios.png'
        OS_IPHONE_UA_STR = 'iPhone'
        OS_WEBOS_UA_STR = 'webos.png'
        OS_IPHONE_IMG = 'iphone.jpg'
        OS_IPAD_UA_STR = 'iPad'
        OS_IPAD_IMG = 'ipad.png'
        OS_IPOD_UA_STR = 'iPod'
        OS_IPOD_IMG = 'ipod.jpg'
        OS_MAEMO_UA_STR = 'Maemo'
        OS_MAEMO_IMG = 'maemo.ico'
        OS_BLACKBERRY_UA_STR = 'BlackBerry'
        OS_BLACKBERRY_IMG = 'blackberry.png'
        OS_ANDROID_UA_STR = 'Android'
        OS_ANDROID_IMG = 'android.png'
        OS_ALL_UA_STR = 'All'

        # Attempt to match operating system string to constant
        # @param [String] name Name of operating system
        # @return [String] Constant name of matched operating system, returns 'ALL'  if nothing are matched
        def self.match_os(name)
          case name.downcase
            when /win/
              OS_WINDOWS_UA_STR
            when /lin/
              OS_LINUX_UA_STR
            when /os x/, /osx/, /mac/
              OS_MAC_UA_STR
            when /qnx/
              OS_QNX_UA_STR
            when /beos/
              OS_BEOS_UA_STR
            when /openbsd/
              OS_OPENBSD_UA_STR
            when /ios/, /iphone/, /ipad/, /ipod/
              OS_IOS_UA_STR
            when /maemo/
              OS_MAEMO_UA_STR
            when /blackberry/
              OS_BLACKBERRY_UA_STR
            when /android/
              OS_ANDROID_UA_STR
            else
              'ALL'
          end
        end

      end

    end
  end
end
