#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the webrtc signals from a hooked_browser, directed to a target_hooked_browser
  #
  class Rtcsignal
  
    include DataMapper::Resource
    
    storage_names[:default] = 'extension_webrtc_rtcsignals'
    
    property :id, Serial

    # The hooked browser id
    property :hooked_browser_id, Text, :lazy => false

    # The target hooked browser id
    property :target_hooked_browser_id, Text, :lazy => false

    # The WebRTC signal to submit. In clear text.
    property :signal , Text, :lazy => true

    # Boolean value to say if the signal has been sent to the target peer
    property :has_sent, Text, :lazy => false, :default => "waiting"

  end
  
end
end
end
