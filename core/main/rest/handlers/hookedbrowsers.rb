#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Rest
      class HookedBrowsers < BeEF::Core::Router::Router

        config = BeEF::Core::Configuration.instance

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          halt 401 if not BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        #
        # @note Return a can of Leffe to the thirsty Bovine Security Team member. AthCon2012 joke /antisnatchor/
        #
        #get "/to/a/pub"
        #  "BeER please"
        #end

        #
        # @note Get online and offline hooked browsers details (like name, version, os, ip, port, ...)
        #
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

        #
        # @note Get all the hooked browser details (plugins enabled, technologies enabled, cookies)
        #
        get '/:session' do
          hb = BeEF::Core::Models::HookedBrowser.first(:session => params[:session])
          error 401 unless hb != nil

          details = BeEF::Core::Models::BrowserDetails.all(:session_id => hb.session)
          result = {}
          details.each do |property|
            result[property.detail_key] = property.detail_value
          end
          result.to_json
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
           details = BeEF::Core::Models::BrowserDetails

           {
               'id'       => hb.id,
               'session'  => hb.session,
               'name'     => details.get(hb.session, 'BrowserName'),
               'version'  => details.get(hb.session, 'BrowserVersion'),
               'os'       => details.get(hb.session, 'OsName'),
               'platform' => details.get(hb.session, 'BrowserPlatform'),
               'ip'       => hb.ip,
               'domain'   => details.get(hb.session, 'HostName'),
               'port'     => hb.port.to_s,
               'page_uri' => details.get(hb.session, 'PageURI')
           }
        end

      end
    end
  end
end
