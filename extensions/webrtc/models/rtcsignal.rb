#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the webrtc signals from a hooked_browser, directed to a target_hooked_browser
  #
  class Rtcsignal < ActiveRecord::Base
    attribute :id, :Serial

    # The hooked browser id
    attribute :hooked_browser_id, :Text, :lazy => false

    # The target hooked browser id
    attribute :target_hooked_browser_id, :Text, :lazy => false

    # The WebRTC signal to submit. In clear text.
    attribute :signal , :Text, :lazy => true

    # Boolean value to say if the signal has been sent to the target peer
    attribute :has_sent, :Text, :lazy => false, :default => "waiting"
  

  end
  
end
end
end
