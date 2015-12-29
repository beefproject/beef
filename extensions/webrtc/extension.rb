#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module WebRTC

	extend BeEF::API::Extension

    @short_name = 'webrtc'
    @full_name = 'WebRTC'
    @description = 'WebRTC extension to all browsers to connect to each other (P2P) with WebRTC'
  
end
end
end

require 'extensions/webrtc/models/rtcsignal'
require 'extensions/webrtc/models/rtcmanage'
require 'extensions/webrtc/models/rtcstatus'
require 'extensions/webrtc/models/rtcmodulestatus'
require 'extensions/webrtc/api/hook'
require 'extensions/webrtc/handlers'
require 'extensions/webrtc/api'
require 'extensions/webrtc/rest/webrtc'
