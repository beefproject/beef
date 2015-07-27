#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Rest
      class AutorunEngine < BeEF::Core::Router::Router

        config = BeEF::Core::Configuration.instance

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          halt 401 if not BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Add a new ruleset. Returne the rule_id if request was successful
        post '/rule/add' do
          request.body.rewind
          begin
            data = JSON.parse request.body.read
            rloader = BeEF::Core::AutorunEngine::RuleLoader.instance
            rloader.load(data)
          rescue => e
              err = 'Malformed JSON ruleset.'
              print_error "[ARE] Ruleset ERROR. #{e.message}"
              { 'success' => false, 'error' => err }.to_json
          end
        end

        # Trigger a specified rule_id on online hooked browsers. Offline hooked browsers are ignored
        post '/rule/trigger/:rule_id' do
          begin
            rule_id = params[:rule_id]

            online_hooks = BeEF::Core::Models::HookedBrowser.all(:lastseen.gte => (Time.new.to_i - 15))
            are = BeEF::Core::AutorunEngine::Engine.instance

            if online_hooks != nil
              online_hooks.each do |hb|
                hb_details = BeEF::Core::Models::BrowserDetails
                browser_name    = hb_details.get(hb.session, 'BrowserName')
                browser_version = hb_details.get(hb.session, 'BrowserVersion')
                os_name = hb_details.get(hb.session, 'OsName')
                os_version = hb_details.get(hb.session, 'OsVersion')

                match_rules = are.match(browser_name, browser_version, os_name, os_version, rule_id)
                are.trigger(match_rules, hb.id) if match_rules.length > 0
              end
            else
              { 'success' => false, 'error' => 'There are currently no hooked browsers online.' }.to_json
            end
          rescue => e
            err = 'Malformed JSON ruleset.'
            print_error "[ARE] Something went wrong #{e.message}"
            { 'success' => false, 'error' => err }.to_json
          end
        end
      end
    end
  end
end