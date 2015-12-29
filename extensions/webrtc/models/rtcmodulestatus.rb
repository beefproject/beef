#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
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
  

  class Rtcmodulestatus
  
    include DataMapper::Resource
    
    storage_names[:default] = 'extension_webrtc_rtcmodulestatus'
    
    property :id, Serial

    # The hooked browser id
    property :hooked_browser_id, Text, :lazy => false

    # The hooked browser's IP
    # property :hooked_browser_ip, Text, :lazy => false

    # The target hooked browser id
    property :target_hooked_browser_id, Text, :lazy => false

    # The command module ID
    property :command_module_id, Text, :lazy => false

    # The status field
    property :status, Text, :lazy => true

    # Timestamps
    property :created_at, DateTime
    property :updated_at, DateTime

  end
  
end
end
end
