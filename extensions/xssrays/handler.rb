#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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

  class Handler < WEBrick::HTTPServlet::AbstractServlet
    attr_reader :guard
    
    XS = BeEF::Core::Models::Xssraysscan
    XD = BeEF::Core::Models::Xssraysdetail
    HB = BeEF::Core::Models::HookedBrowser

    #
    # Class constructor
    #
    def initialize(data)
      # we set up a mutex
      @guard = Mutex.new
      @data = data
      setup()
    end
    
    def setup()

      # validates the hook token
      beef_hook = @data['beefhook'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "beefhook is null" if beef_hook.nil?
      
      # validates the scan id
      scan_id = @data['cid'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "Scan id (cid) is null" if request_id.nil?

      # validates that a hooked browser with the beef_hook token exists in the db
      hooked_browser = HB.first(:session => beef_hook) || nil
      raise WEBrick::HTTPStatus::BadRequest, "Invalid beefhook id: the hooked browser cannot be found in the database" if hooked_browser.nil?
      
      # update the XssRays scan table, marking the scan as finished
      xssrays_scan = BeEF::Core::Models::Xssraysscan.first(:id => scan_id)

      if(xssrays_scan != nil)
         xssrays_scan.update(:is_finished => true, :scan_finish => Time.now)
         print_info("[XSSRAYS] Scan id [#{xssrays_scan.id}] finished at [#{xssrays_scan.scan_finish}]")
      end
    end

  end
  
end
end
end
