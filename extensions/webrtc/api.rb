#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module WebRTC
  
  module RegisterHttpHandler
    
    BeEF::API::Registrar.instance.register(BeEF::Extension::WebRTC::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')
    
    # We register the http handler for the WebRTC signalling extension.
    # This http handler will handle WebRTC signals from browser to browser

    # We also define an rtc message handler, so that the beefwebrtc object can send messages back into BeEF
    def self.mount_handler(beef_server)
      beef_server.mount('/rtcsignal', BeEF::Extension::WebRTC::SignalHandler)
      beef_server.mount('/rtcmessage', BeEF::Extension::WebRTC::MessengeHandler)
      beef_server.mount('/api/webrtc', BeEF::Extension::WebRTC::WebRTCRest.new)
    end
    
  end

  module RegisterPreHookCallback

    BeEF::API::Registrar.instance.register(BeEF::Extension::WebRTC::RegisterPreHookCallback, BeEF::API::Server::Hook, 'pre_hook_send')

    # We register this pre hook action to ensure that signals going to a browser are included back in the hook.js polling
    # This is also used so that BeEF can send RTCManagement messages to the hooked browser too
    def self.pre_hook_send(hooked_browser, body, params, request, response)
        dhook = BeEF::Extension::WebRTC::API::Hook.new
        dhook.requester_run(hooked_browser, body)
    end

  end
  
end
end
end
