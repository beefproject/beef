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
#
#
class Panel < BeEF::Extension::AdminUI::HttpController
  
  def initialize
    super({
      'paths' => {
        '/' => method(:index),
        '/hooked-browser-tree-update.json' => method(:hooked_browser_tree_update)
      }
    })
  end
  
  # default index page
  def index; end
  
  # return a JSON object contains all the updates for the hooked browser trees
  def hooked_browser_tree_update
    # retrieve the hbs that are online
    hooked_browsers_online = zombies2json_simple(BeEF::Core::Models::HookedBrowser.all(:lastseen.gte => (Time.new.to_i - 30)))
    
    # retrieve the hbs that are offline
    hooked_browsers_offline = zombies2json_simple(BeEF::Core::Models::HookedBrowser.all(:lastseen.lt => (Time.new.to_i - 30)))
    
    # retrieve the distributed engine rules that are enabled
    distributed_engine_rules = distributed_engine_rules_2_json_simple(BeEF::Core::DistributedEngine::Models::Rules.all(:enabled => true))
    
    # hash that gets populated with all the information for the hb trees
    ret = {
      'success' => true,
      
      # the list of hb
      'hooked-browsers' => {
        'online' => hooked_browsers_online,
        'offline' => hooked_browsers_offline
      },
      
      # the rules for the distributed engine
      'ditributed-engine-rules' => distributed_engine_rules
    }
    
    @body = ret.to_json
  end
  
  # Takes a list distributed engine rules and format the results into JSON
  def distributed_engine_rules_2_json_simple(rules)

  end
  
  # Takes a list of zombies and format the results in a JSON array.
  def zombies2json_simple(zombies)
    zombies_hash = {}
    i = 0
    
    zombies.each do |zombie|
      # create hash of zombie details
      zombies_hash[i] = (get_simple_hooked_browser_hash(zombie))
      i+=1
    end
    
    zombies_hash
  end
  
  # create a hash of simple hooked browser details
  def get_simple_hooked_browser_hash(hooked_browser)
    
    browser_icon = BeEF::Extension::Initialization::Models::BrowserDetails.browser_icon(hooked_browser.session)
    os_icon = BeEF::Extension::Initialization::Models::BrowserDetails.os_icon(hooked_browser.session)
    domain = BeEF::Extension::Initialization::Models::BrowserDetails.get(hooked_browser.session, 'HostName')
    
    return {
      'session' => hooked_browser.session,
      'ip' => hooked_browser.ip,
      'domain' => domain,
      'port' => hooked_browser.port.to_s,
      'browser_icon' => browser_icon,
      'os_icon' => os_icon
    }
    
  end
end

end
end
end
end
