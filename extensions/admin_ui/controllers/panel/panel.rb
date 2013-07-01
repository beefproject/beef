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
          def index;
          end

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

            browser_name    = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'BrowserName')
            browser_version = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'BrowserVersion')
            browser_icon    = BeEF::Core::Models::BrowserDetails.browser_icon(hooked_browser.session)
            os_icon         = BeEF::Core::Models::BrowserDetails.os_icon(hooked_browser.session)
            os_name         = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'OsName')
            hw_icon         = BeEF::Core::Models::BrowserDetails.hw_icon(hooked_browser.session)
            hw_name         = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'Hardware')
            domain          = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HostName')
            has_flash       = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasFlash')
            has_web_sockets = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasWebSocket')
            has_googlegears = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasGoogleGears')
            has_java        = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'JavaEnabled')
            has_webrtc      = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasWebRTC')
            has_activex     = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasActiveX')
            has_silverlight = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasSilverlight')
            has_quicktime   = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasQuickTime')
            has_realplayer  = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasRealPlayer')
            has_wmp         = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasWMP') 
            has_vlc         = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasVLC')
            has_foxit       = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'HasFoxit')
            date_stamp      = BeEF::Core::Models::BrowserDetails.get(hooked_browser.session, 'DateStamp')

            return {
                'session'         => hooked_browser.session,
                'ip'              => hooked_browser.ip,
                'domain'          => domain,
                'port'            => hooked_browser.port.to_s,
                'browser_name'    => browser_name,
                'browser_version' => browser_version,
                'browser_icon'    => browser_icon,
                'os_icon'         => os_icon,
                'os_name'         => os_name,
                'hw_icon'         => hw_icon,
                'hw_name'         => hw_name,
                'has_flash'       => has_flash,
                'has_web_sockets' => has_web_sockets,
                'has_googlegears' => has_googlegears,
                'has_java'        => has_java,
                'has_webrtc'      => has_webrtc,
                'has_activex'     => has_activex,
                'has_silverlight' => has_silverlight,
                'has_quicktime'   => has_quicktime,
                'has_wmp'         => has_wmp,
                'has_vlc'         => has_vlc,
                'has_foxit'       => has_foxit,
                'has_realplayer'  => has_realplayer,
                'date_stamp'      => date_stamp
            }

          end
        end

      end
    end
  end
end
