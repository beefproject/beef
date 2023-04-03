#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
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
          halt 401 unless BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        #
        # @note Get online and offline hooked browsers details (like name, version, os, ip, port, ...)
        # When websockets are enabled this will allow the ws_poll_timeout config to be used to check if the browser is online or not.
        #
        get '/' do
          if config.get('beef.http.websocket.enable') == false
            online_hooks = hb_to_json(BeEF::Core::Models::HookedBrowser.where('lastseen >= ?', (Time.new.to_i - 15)))
            offline_hooks = hb_to_json(BeEF::Core::Models::HookedBrowser.where('lastseen <= ?', (Time.new.to_i - 15)))
          # If we're using websockets use the designated threshold timeout to determine live, instead of hardcoded 15
          # Why is it hardcoded 15?
          else
            timeout = config.get('beef.http.websocket.ws_poll_timeout')
            online_hooks = hb_to_json(BeEF::Core::Models::HookedBrowser.where('lastseen >= ?', (Time.new.to_i - timeout)))
            offline_hooks = hb_to_json(BeEF::Core::Models::HookedBrowser.where('lastseen <= ?', (Time.new.to_i - timeout)))
          end

          output = {
            'hooked-browsers' => {
              'online' => online_hooks,
              'offline' => offline_hooks
            }
          }
          output.to_json
        end

        get '/:session/delete' do
          hb = BeEF::Core::Models::HookedBrowser.where(session: params[:session]).first
          error 401 if hb.nil?

          details = BeEF::Core::Models::BrowserDetails.where(session_id: hb.session)
          details.destroy_all

          logs = BeEF::Core::Models::Log.where(hooked_browser_id: hb.id)
          logs.destroy_all

          commands = BeEF::Core::Models::Command.where(hooked_browser_id: hb.id)
          commands.destroy_all

          results = BeEF::Core::Models::Result.where(hooked_browser_id: hb.id)
          results.destroy_all

          begin
            requester = BeEF::Core::Models::Http.where(hooked_browser_id: hb.id)
            requester.destroy_all
          rescue StandardError
            # @todo why is this error swallowed?
            # the requester module may not be enabled
          end

          begin
            xssraysscans = BeEF::Core::Models::Xssraysscan.where(hooked_browser_id: hb.id)
            xssraysscans.destroy_all

            xssraysdetails = BeEF::Core::Models::Xssraysdetail.where(hooked_browser_id: hb.id)
            xssraysdetails.destroy_all
          rescue StandardError => e
            # @todo why is this error swallowed?
            # the xssraysscan module may not be enabled
          end

          hb.destroy
        end

        #
        # @note returns all zombies
        #
        get '/all' do
          hbs = []
          BeEF::Core::Models::HookedBrowser.all.each do |hook|
            hbs << get_hb_details(hook)
          end

          output = {
            'count' => hbs.length,
            'zombies' => hbs
          }

          output.to_json
        end

        #
        # @note Get all the hooked browser details (plugins enabled, technologies enabled, cookies)
        #
        get '/:session' do
          hb = BeEF::Core::Models::HookedBrowser.where(session: params[:session]).first
          error 401 if hb.nil?

          details = BeEF::Core::Models::BrowserDetails.where(session_id: hb.session)
          result = {}
          details.each do |property|
            result[property.detail_key] = property.detail_value
          end
          result.to_json
        end

        # useful when you inject the BeEF hook in MITM situations (see MITMf) and you want to feed back
        # to BeEF a more accurate OS type/version and architecture information
        post '/update/:session' do
          body = JSON.parse request.body.read
          os = body['os']
          os_version = body['os_version']
          arch = body['arch']

          hb = BeEF::Core::Models::HookedBrowser.where(session: params[:session]).first
          error 401 if hb.nil?

          BeEF::Core::Models::BrowserDetails.where(session_id: hb.session, detail_key: 'host.os.name').destroy
          BeEF::Core::Models::BrowserDetails.where(session_id: hb.session, detail_key: 'host.os.version').destroy
          # BeEF::Core::Models::BrowserDetails.first(:session_id => hb.session, :detail_key => 'Arch').destroy

          BeEF::Core::Models::BrowserDetails.create(session_id: hb.session, detail_key: 'host.os.name', detail_value: os)
          BeEF::Core::Models::BrowserDetails.create(session_id: hb.session, detail_key: 'host.os.version', detail_value: os_version)
          BeEF::Core::Models::BrowserDetails.create(session_id: hb.session, detail_key: 'Arch', detail_value: arch)

          # TODO: if there where any ARE rules defined for this hooked browser,
          # after updating OS/arch, force a retrigger of the rule.
          { 'success' => true }.to_json
        end

        def hb_to_json(hbs)
          hbs_hash = {}
          i = 0
          hbs.each do |hb|
            hbs_hash[i] = get_hb_details(hb)
            i += 1
          end
          hbs_hash
        end

        def get_hb_details(hb)
          details = BeEF::Core::Models::BrowserDetails

          {
            'id' => hb.id,
            'session' => hb.session,
            'name' => details.get(hb.session, 'browser.name'),
            'version' => details.get(hb.session, 'browser.version'),
            'platform' => details.get(hb.session, 'browser.platform'),
            'os' => details.get(hb.session, 'host.os.name'),
            'os_version' => details.get(hb.session, 'host.os.version'),
            'hardware' => details.get(hb.session, 'hardware.type'),
            'ip' => hb.ip,
            'domain' => details.get(hb.session, 'browser.window.hostname'),
            'port' => hb.port.to_s,
            'page_uri' => details.get(hb.session, 'browser.window.uri'),
            'firstseen' => hb.firstseen,
            'lastseen' => hb.lastseen,
            'date_stamp' => details.get(hb.session, 'browser.date.datestamp'),
            'city' => details.get(hb.session, 'location.city'),
            'country' => details.get(hb.session, 'location.country'),
            'country_code' => details.get(hb.session, 'location.country.isocode')
          }
        end
      end
    end
  end
end
