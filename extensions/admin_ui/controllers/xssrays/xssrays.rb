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
module AdminUI
module Controllers

class Xssrays < BeEF::Extension::AdminUI::HttpController

  HB = BeEF::Core::Models::HookedBrowser
  XS = BeEF::Core::Models::Xssraysscan
  XD = BeEF::Core::Models::Xssraysdetail

  # default values from config file, when XssRays is started right-clicking the zombie in the HB tree
  CLEAN_TIMEOUT = BeEF::Core::Configuration.instance.get("beef.extension.xssrays.clean_timeout")
  CROSS_DOMAIN = BeEF::Core::Configuration.instance.get("beef.extension.xssrays.cross_domain")

  def initialize
    super({
      'paths' => {
        '/set_scan_target' => method(:set_scan_target),
        '/zombie.json'  => method(:get_xssrays_logs),
        '/rays' => method(:parse_rays),
        '/createNewScan' => method(:create_new_scan)
      }
    })
  end

  # called by the UI when rendering xssrays_details table content in the XssRays zombie tab
  def get_xssrays_logs
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce

    # validate that the hooked browser's session has been sent
    zombie_session = @params['zombie_session'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Zombie session is nil" if zombie_session.nil?

    # validate that the hooked browser exists in the db
    zombie = Z.first(:session => zombie_session) || nil
    raise WEBrick::HTTPStatus::BadRequest, "Invalid hooked browser session" if zombie.nil?

    logs = []
    BeEF::Core::Models::Xssraysdetail.all(:hooked_browser_id => zombie.id).each{|log|
      logs << {
        'id'      => log.id,
        'vector_method'  => log.vector_method,
        'vector_name'    => log.vector_name,
        'vector_poc' => escape_for_html(log.vector_poc)
      }
    }

    @body = {'success' => 'true', 'logs' => logs}.to_json
  end

  def escape_for_html(str)
        str.gsub!(/</, '&lt;')
        str.gsub!(/>/, '&gt;')
        str.gsub!(/\u0022/, '&quot;')
        str.gsub!(/\u0027/, '&#39;')
        str.gsub!(/\\/, '&#92;')
    str
  end

   # called by the UI. needed to pass the hooked browser ID/session and store a new scan in the DB.
   # This is called when right-clicking the hooked browser from the tree. Default config options are read from config.yaml
   def set_scan_target
    hooked_browser = HB.first(:session => @params['hb_id'].to_s)
    if(hooked_browser != nil)
      xssrays_scan = XS.new(
          :hooked_browser_id => hooked_browser.id,
          :scan_start => Time.now,
          :domain => hooked_browser.domain,
          :cross_domain => CROSS_DOMAIN, #check also cross-domain URIs found by the spider
          :clean_timeout => CLEAN_TIMEOUT #check also cross-domain URIs found by the spider
      )
      xssrays_scan.save

      print_info("[XSSRAYS] Starting XSSRays on HB with ip [#{hooked_browser.ip.to_s}], hooked on domain [#{hooked_browser.domain.to_s}]")
    end

   end

   # called by the UI, in the XssRays zombie tab
   # Needed if we want to start a scan overriding default scan parameters without rebooting BeEF
  def create_new_scan
    hooked_browser = HB.first(:session => @params['zombie_session'].to_s)
    if(hooked_browser != nil)

      # set Cross-domain settings
      cross_domain =  @params['cross_domain']
      if cross_domain.nil? or cross_domain.empty?
         cross_domain = CROSS_DOMAIN
      else
         cross_domain = true
      end
      print_debug("[XSSRAYS] Setting scan cross_domain to #{cross_domain}")

       # set Clean-timeout settings
      clean_timeout =  @params['clean_timeout']
      if clean_timeout.nil? or clean_timeout.empty?
         clean_timeout = CLEAN_TIMEOUT
      end
      print_debug("[XSSRAYS] Setting scan clean_timeout to #{clean_timeout}")

      xssrays_scan = XS.new(
          :hooked_browser_id => hooked_browser.id,
          :scan_start => Time.now,
          :domain => hooked_browser.domain,
          :cross_domain => cross_domain, #check also cross-domain URIs found by the spider
          :clean_timeout => clean_timeout #check also cross-domain URIs found by the spider
      )
      xssrays_scan.save

      print_info("[XSSRAYS] Starting XSSRays on HB with ip [#{hooked_browser.ip.to_s}], hooked on domain [#{hooked_browser.domain.to_s}]")
    end

   end

   # parse incoming rays: rays are veryfied XSS, as the attack vector is calling back BeEF when executed.
   def parse_rays
      print_debug("[XSSRAYS] Received ray: \n #{@params.to_s}")

      hooked_browser = HB.first(:session => @params['hbsess'].to_s)

      if(hooked_browser != nil)

        xssrays_scan = XS.first(:id => @params['raysscanid'])

        if(xssrays_scan != nil)
           xssrays_detail = XD.new(
             :hooked_browser_id => hooked_browser.id,
             :vector_name => @params['name'],
             :vector_method => @params['method'],
             :vector_poc => @params['poc'],
             :scan_id => xssrays_scan.id
           )
          xssrays_detail.save
        end

        print_info("[XSSRAYS] Received ray from HB with ip [#{hooked_browser.ip.to_s}], hooked on domain [#{hooked_browser.domain.to_s}]")
      end
   end
end

end
end
end
end