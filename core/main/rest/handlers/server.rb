#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core
    module Rest
      class Server < BeEF::Core::Router::Router

        config = BeEF::Core::Configuration.instance
        http_server = BeEF::Core::Server.instance

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          halt 401 if not BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end


        # @note Binds a local file to a specified path in BeEF's web server
        post '/bind' do
          request.body.rewind
          begin
            data = JSON.parse request.body.read
            mount = data['mount']
            local_file = data['local_file']
            BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(local_file, mount)
            status 200
          rescue Exception => e
            error 400
          end
        end
      end
    end
  end
end