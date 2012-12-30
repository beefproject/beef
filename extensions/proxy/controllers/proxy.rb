#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module AdminUI
module Controllers

#
# HTTP Controller for the Proxy component of BeEF.
#
class Proxy < BeEF::Extension::AdminUI::HttpController

  H = BeEF::Core::Models::Http
  HB = BeEF::Core::Models::HookedBrowser

  def initialize
    super({
      'paths' => {
        '/setTargetZombie' => method(:set_target_zombie)
      }
    })
  end


  def set_target_zombie
    hb_session_id = @params['hb_id'].to_s
    hooked_browser = HB.first(:session => hb_session_id)
    previous_proxy_hb = HB.first(:is_proxy => true)

    # if another HB is currently set as tunneling proxy, unset it
    if(previous_proxy_hb != nil)
      previous_proxy_hb.update(:is_proxy => false)
      print_debug("Unsetting previously HB [#{previous_proxy_hb.ip.to_s}] used as Tunneling Proxy")
    end

    # set the HB requested in /setTargetProxy as Tunneling Proxy
    if(hooked_browser != nil)
      hooked_browser.update(:is_proxy => true)
      print_info("Using Hooked Browser with ip [#{hooked_browser.ip.to_s}] as Tunneling Proxy")
    end
  end

end

end
end
end
end
