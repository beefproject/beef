#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
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
  

  class Rtcstatus < ActiveRecord::Base
    attribute :id, :Serial

    # The hooked browser id
    attribute :hooked_browser_id, :Text, :lazy => false

    # The hooked browser's IP
    # property :hooked_browser_ip, Text, :lazy => false

    # The target hooked browser id
    attribute :target_hooked_browser_id, :Text, :lazy => false

    # The target hooked browser's IP
    # property :target_hooked_browser_ip, Text, :lazy => false

    # The status field
    attribute :status, :Text, :lazy => true

    # Timestamps
    attribute :created_at, DateTime
    attribute :updated_at, DateTime
  

  end
  
end
end
end
