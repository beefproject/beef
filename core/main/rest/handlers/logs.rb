#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Rest
      class Logs < BeEF::Core::Router::Router

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
        # @note Get all global logs
        #
        get '/' do
          logs = BeEF::Core::Models::Log.all()
          logs_to_json(logs)
        end

        #
        # @note Get hooked browser logs
        #
        get '/:session' do
          hb = BeEF::Core::Models::HookedBrowser.first(:session => params[:session])
          error 401 unless hb != nil

          logs = BeEF::Core::Models::Log.all(:hooked_browser_id => hb.id)
          logs_to_json(logs)
        end

        private

        def logs_to_json(logs)
          logs_json = []
          count = logs.length

          logs.each do |log|
            logs_json << {
                'id' => log.id.to_i,
                'date' => log.date.to_s,
                'event' => log.event.to_s,
                'type' => log.type.to_s
            }
          end

          {
              'logs_count' => count,
              'logs' => logs_json
          }.to_json if not logs_json.empty?

        end

      end
    end
  end
end