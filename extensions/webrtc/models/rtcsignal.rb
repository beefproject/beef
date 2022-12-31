#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the webrtc signals from a hooked_browser, directed to a target_hooked_browser
  #
  class RtcSignal < BeEF::Core::Model

    belongs_to :hooked_browser

  end
  
end
end
end
