#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
module Core
module Models
  #
  # Table stores the webrtc status information
  # This includes things like connection status, and executed modules etc
  #
  

  class Rtcstatus < BeEF::Core::Model
  
    belongs_to :hooked_browser

  end
  
end
end
end
