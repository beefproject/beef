#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
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

	get '/:session/delete' do
          hb = BeEF::Core::Models::HookedBrowser.first(:session => params[:session])
          error 401 unless hb != nil

          details = BeEF::Core::Models::BrowserDetails.all(:session_id => hb.session)
	  details.destroy

	  logs = BeEF::Core::Models::Log.all(:hooked_browser_id => hb.id)
	  logs.destroy

	  commands = BeEF::Core::Models::Command.all(:hooked_browser_id => hb.id)
	  commands.destroy

	  results = BeEF::Core::Models::Result.all(:hooked_browser_id => hb.id)
	  results.destroy

	  begin
	    requester = BeEF::Core::Models::Http.all(:hooked_browser_id => hb.id)
	    requester.destroy
	  rescue => e
	    #the requester module may not be enabled
	  end

	  begin
	    xssraysscans = BeEF::Core::Models::Xssraysscan.all(:hooked_browser_id => hb.id)
	    xssraysscans.destroy

	    xssraysdetails = BeEF::Core::Models::Xssraysdetail.all(:hooked_browser_id => hb.id)
	    xssraysdetails.destroy
	  rescue => e
	    #the xssraysscan module may not be enabled
	  end

	  hb.destroy
	end

        #
        # @note this is basically the same call as /api/hooks, but returns different data structured in arrays rather than objects.
        # Useful if you need to query the API via jQuery.dataTable < 1.10 which is currently used in PhishingFrenzy
        #
        get '/pf/online' do
          online_hooks = hbs_to_array(BeEF::Core::Models::HookedBrowser.all(:lastseen.gte => (Time.new.to_i - 15)))

          output = {
              'aaData' => online_hooks
          }
          output.to_json
        end

        #
        # @note this is basically the same call as /api/hooks, but returns different data structured in arrays rather than objects.
        # Useful if you need to query the API via jQuery.dataTable < 1.10 which is currently used in PhishingFrenzy
        #
        get '/pf/offline' do
          offline_hooks = hbs_to_array(BeEF::Core::Models::HookedBrowser.all(:lastseen.lt => (Time.new.to_i - 15)))

          output = {
              'aaData' => offline_hooks
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
              'id' => hb.id,
              'session' => hb.session,
              'name' => details.get(hb.session, 'BrowserName'),
              'version' => details.get(hb.session, 'BrowserVersion'),
              'os' => details.get(hb.session, 'OsName'),
              'platform' => details.get(hb.session, 'BrowserPlatform'),
              'ip' => hb.ip,
              'domain' => details.get(hb.session, 'HostName'),
              'port' => hb.port.to_s,
              'page_uri' => details.get(hb.session, 'PageURI')
          }
        end

        # this is used in the 'get '/pf'' restful api call
        def hbs_to_array(hbs)
          hbs_online = []
          hbs.each do |hb|
            details = BeEF::Core::Models::BrowserDetails
            # TODO jQuery.dataTables needs fixed array indexes, add emptry string if a value is blank
            hbs_online << [
                hb.id,
                hb.ip,
                details.get(hb.session, 'PhishingFrenzyUID'),
                details.get(hb.session, 'BrowserName'),
                details.get(hb.session, 'BrowserVersion'),
                details.get(hb.session, 'OsName'),
                details.get(hb.session, 'BrowserPlatform'),
                details.get(hb.session, 'BrowserLanguage'),
                details.get(hb.session, 'BrowserPlugins'),
                details.get(hb.session, 'LocationCity'),
                details.get(hb.session, 'LocationCountry'),
                details.get(hb.session, 'LocationLatitude'),
                details.get(hb.session, 'LocationLongitude')
            ]
          end
          hbs_online
        end

      end
    end
  end
end
