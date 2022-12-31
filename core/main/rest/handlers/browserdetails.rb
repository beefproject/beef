#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Rest
      class BrowserDetails < BeEF::Core::Router::Router
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
        # @note Get all browser details for the specified session
        #
        get '/:session' do
          hb = BeEF::Core::Models::HookedBrowser.where(session: params[:session]).first
          error 404 if hb.nil?

          details = BeEF::Core::Models::BrowserDetails.where(session_id: hb.session)
          error 404 if details.nil?

          result = []
          details.each do |d|
            result << { key: d[:detail_key], value: d[:detail_value] }
          end

          output = {
            'count' => result.length,
            'details' => result
          }

          output.to_json
        end
      end
    end
  end
end
