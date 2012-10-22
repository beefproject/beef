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
