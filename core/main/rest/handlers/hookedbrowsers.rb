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
  module Core
    module Rest
      class HookedBrowsers < Sinatra::Base

        config = BeEF::Core::Configuration.instance
        configure do set :show_exceptions, false end
        not_found do 'Not Found.' end

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # @note Get online and offline hooked browsers details (like name, version, os, ip, port, ...)
        get '/' do
          online_hooks = hb_to_json(BeEF::Core::Models::HookedBrowser.all(:lastseen.gte => (Time.new.to_i - 15)))
          offline_hooks = hb_to_json(BeEF::Core::Models::HookedBrowser.all(:lastseen.lt => (Time.new.to_i - 15)))

          output = {
              'hooked-browsers' => {
                  'online' => online_hooks,
                  'offline' => offline_hooks
              }
          }
          output.to_json
        end

        def hb_to_json(hbs)
          hbs_hash = {}
          i = 0
          hbs.each do |hb|
            hbs_hash[i] = (get_hb_details(hb))
            i+=1
          end
          hbs_hash
        end

        def get_hb_details(hb)
           details = BeEF::Extension::Initialization::Models::BrowserDetails

           {
               'name' => details.get(hb.session, 'BrowserName'),
               'version' => details.get(hb.session, 'BrowserVersion'),
               'os' => details.get(hb.session, 'OsName'),
               'platform' => details.get(hb.session, 'SystemPlatform'),
               'session' => hb.session,
               'ip' => hb.ip,
               'domain' => details.get(hb.session, 'HostName'),
               'port' => hb.port.to_s,
               'page_uri' => details.get(hb.session, 'PageURI')
           }
        end

      end
    end
  end
end