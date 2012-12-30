#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
        '/createNewScan' => method(:create_new_scan)
      }
    })
  end

  # called by the UI when rendering xssrays_details table content in the XssRays zombie tab
  def get_xssrays_logs
    # validate nonce
    nonce = @params['nonce'] || nil
    (print_error "nonce is nil";return @body = {'success' => 'false'}.to_json) if nonce.nil?
    (print_error "nonce incorrect";return @body = {'success' => 'false'}.to_json) if @session.get_nonce != nonce

    # validate that the hooked browser's session has been sent
    zombie_session = @params['zombie_session'] || nil
    (print_error "Zombie session is nil";return @body = {'success' => 'false'}.to_json) if zombie_session.nil?

    # validate that the hooked browser exists in the db
    zombie = Z.first(:session => zombie_session) || nil
    (print_error "Invalid hooked browser session";return @body = {'success' => 'false'}.to_json) if zombie.nil?

    logs = []
    BeEF::Core::Models::Xssraysdetail.all(:hooked_browser_id => zombie.id).each{|log|
      logs << {
        'id'      => log.id,
        'vector_method'  => log.vector_method,
        'vector_name'    => log.vector_name,
        'vector_poc' => log.vector_poc
      }
    }

    @body = {'success' => 'true', 'logs' => logs}.to_json
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

      print_info("[XSSRAYS] Starting XSSRays [ip:#{hooked_browser.ip.to_s}], hooked domain [#{hooked_browser.domain.to_s}]")
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
          :cross_domain => cross_domain, #check also cross-domain URIs found by the crawler
          :clean_timeout => clean_timeout #how long to wait before removing the iFrames from the DOM (5000ms default)
      )
      xssrays_scan.save

      print_info("[XSSRAYS] Starting XSSRays [ip:#{hooked_browser.ip.to_s}], hooked domain [#{hooked_browser.domain.to_s}]")
    end
   end
end

end
end
end
end
