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
      class Modules < Sinatra::Base

        config = BeEF::Core::Configuration.instance

        before do
          error 401 unless params[:token] == config.get('beef.api_token')
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # @note Get all available modules
        get '/' do
          "return available modules"
        end

        # @note Get the module definition (info, options, targets)
        get '/:session/:mod_id' do

        end

        # @note Get the module result for the specific executed command
        #
        # Example with the Alert Dialog
        #GET /api/modules/wiJCKAJybcB6aXZZOj31UmQKhbKXY63aNBeODl9kvkIuYLmYTooeGeRD7Xn39x8zOChcUReM3Bt7K0xj/86/1?token=0a931a461d08b86bfee40df987aad7e9cfdeb050 HTTP/1.1
        #Host: 127.0.0.1:3000
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"date":"1331637093","data":"{\"data\":\"text=michele\"}"}
        get '/:session/:mod_id/:cmd_id' do
          hb = BeEF::Core::Models::HookedBrowser.first(:session => params[:session])
          error 401 unless hb != nil
          cmd = BeEF::Core::Models::Command.first(:hooked_browser_id => hb.id,
                                                  :command_module_id => params[:mod_id], :id => params[:cmd_id])
          error 404 unless cmd != nil
          result = BeEF::Core::Models::Result.first(:hooked_browser_id => hb.id, :command_id => cmd.id)
          error 404 unless result != nil
          {
             'date' => result.date,
             'data' => result.data
          }.to_json
        end

        # @note Fire a new command module to the specified hooked browser.
        # Return the command_id of the executed module if it has been fired correctly.
        # Input must be specified in JSON format
        #
        # Example with the Alert Dialog:
        #POST /api/modules/wiJCKAJybcB6aXZZOj31UmQKhbKXY63aNBeODl9kvkIuYLmYTooeGeRD7Xn39x8zOChcUReM3Bt7K0xj/86?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #Content-Type: application/json; charset=UTF-8
        #Content-Length: 18
        #
        #{"text":"michele"}
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #Content-Length: 35
        #
        #{"success":"true","command_id":"1"}
        post '/:session/:mod_id' do
          hb = BeEF::Core::Models::HookedBrowser.first(:session => params[:session])
          error 401 unless hb != nil
          modk = BeEF::Module.get_key_by_database_id(params[:mod_id])
          error 401 unless modk != nil

          request.body.rewind
          begin
            data = JSON.parse request.body.read
            options = []
            data.each{|k,v| options.push({'name' => k, 'value' => v})}
            exec_results = BeEF::Module.execute(modk, params[:session], options)
            exec_results != nil ? '{"success":"true","command_id":"'+exec_results.to_s+'"}' : '{"success":"false"}'
          rescue Exception => e
            print_error "Invalid JSON input for module '#{params[:mod_id]}'"
            error 400 # Bad Request
          end
        end
      end
    end
  end
end