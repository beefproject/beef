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

      class Handler

        XS = BeEF::Core::Models::Xssraysscan
        XD = BeEF::Core::Models::Xssraysdetail
        HB = BeEF::Core::Models::HookedBrowser

        def call(env)
           @request = Rack::Request.new(env)

          # verify if the request contains the hook token
          # raise an exception if it's null or not found in the DB
          beef_hook = @request['hbsess'] || nil
          (print_error "[XSSRAYS] Invalid beefhook id: the hooked browser cannot be found in the database";return) if beef_hook.nil? || HB.first(:session => beef_hook) == nil

          rays_scan_id = @request['raysid'] || nil
          (print_error "[XSSRAYS] Raysid is null";return) if rays_scan_id.nil?

          if @request['action'] == 'ray'
            # we received a ray
            parse_rays(rays_scan_id)
          else
            if @request['action'] == 'finish'
              # we received a notification for finishing the scan
              finalize_scan(rays_scan_id)
            else
              #invalid action
              print_error "[XSSRAYS] Invalid action";return
            end
          end

          response = Rack::Response.new(
              body = [],
              status = 200,
              header = {
                'Pragma' => 'no-cache',
                'Cache-Control' => 'no-cache',
                'Expires' => '0',
                'Content-Type' => 'text/javascript',
                'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => 'POST'
              }
          )
          response
        end

        # parse incoming rays: rays are verified XSS, as the attack vector is calling back BeEF when executed.
        def parse_rays(rays_scan_id)
          xssrays_scan = XS.first(:id => rays_scan_id)
          hooked_browser = HB.first(:session => @request['hbsess'])

          if (xssrays_scan != nil)
            xssrays_detail = XD.new(
                :hooked_browser_id => hooked_browser.id,
                :vector_name => @request['n'],
                :vector_method => @request['m'],
                :vector_poc => @request['p'],
                :xssraysscan_id => xssrays_scan.id
            )
            xssrays_detail.save
          end
          print_info("[XSSRAYS] Scan id [#{xssrays_scan.id}] received ray [ip:#{hooked_browser.ip.to_s}], hooked domain [#{hooked_browser.domain.to_s}]")
          print_debug("[XSSRAYS] Ray info: \n #{@request.query_string}")
        end

        # finalize the XssRays scan marking the scan as finished in the db
        def finalize_scan(rays_scan_id)
          xssrays_scan = BeEF::Core::Models::Xssraysscan.first(:id => rays_scan_id)

          if (xssrays_scan != nil)
            xssrays_scan.update(:is_finished => true, :scan_finish => Time.now)
            print_info("[XSSRAYS] Scan id [#{xssrays_scan.id}] finished at [#{xssrays_scan.scan_finish}]")
          end
        end
      end
    end
  end
end
