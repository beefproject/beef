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

        # @note Get all global logs
        get '/' do
          logs = BeEF::Core::Models::Log.all()
          logs_to_json(logs)
        end

        # @note Get hooked browser logs
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