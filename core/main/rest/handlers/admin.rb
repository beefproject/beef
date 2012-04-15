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
      class Admin < BeEF::Core::Router::Router

        config = BeEF::Core::Configuration.instance

        before do
          # error 401 unless params[:token] == config.get('beef.api_token')
          halt 401 if not BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # @note Authenticate using the config set username/password to retrieve the "token" used for subsquent calls.
        # Return the secret token used for subsquene tAPI calls.
        #
        # Input must be specified in JSON format
        #
        # +++ Example: +++
        #POST /api/admin/login HTTP/1.1
        #Host: 127.0.0.1:3000
        #Content-Type: application/json; charset=UTF-8
        #Content-Length: 18
        #
        #{"username":"beef", "password":"beef"}
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #Content-Length: 35
        #
        #{"success":"true","token":"122323121"}
        #
        post '/login' do
          request.body.rewind
          begin
            data = JSON.parse request.body.read
            # check username and password
            if not (data['username'].eql? config.get('beef.credentials.user') and data['password'].eql? config.get('beef.credentials.passwd') )
              BeEF::Core::Logger.instance.register('Authentication', "User with ip #{request.ip} has failed to authenticate in the application.")
              halt 401
            else
              '{"success":"true","token":"' + config.get('beef.api_token') + '"'
            end
          rescue Exception => e
            error 400
          end
        end

        private

      end
    end
  end
end