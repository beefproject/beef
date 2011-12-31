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
    module Requester
      module API

        require 'uri'
        class Hook

          include BeEF::Core::Handlers::Modules::BeEFJS

          # If the HTTP table contains requests that need to be sent (has_ran = waiting), retrieve
          # and send them to the hooked browser.
          def requester_run(hb, body)
            @body = body
            # Generate all the requests and output them to the hooked browser
            output = []
            BeEF::Core::Models::Http.all(:hooked_browser_id => hb.id, :has_ran => "waiting").each { |h|
              output << self.requester_parse_db_request(h)
            }

            return if output.empty?

            # Build the BeEFJS requester component
            build_missing_beefjs_components 'beef.net.requester'

            # Send the command to perform the requests to the hooked browser
            @body << %Q{
              beef.execute(function() {
                beef.net.requester.send(
                  #{output.to_json}
                );
              });
            }
          end

          #
          # Converts an HTTP db object into an Hash that follows the representation
          # of input data for the beef.net.request Javascript API function.
          # The Hash will then be converted into JSON, given as input to beef.net.requester.send Javascript API function
          # and finally sent to and executed by the hooked browser.
          def requester_parse_db_request(http_db_object)

            allow_cross_domain = http_db_object.allow_cross_domain.to_s
            req_parts = http_db_object.request.split(/ |\n/)
            verb = req_parts[0]
            uri = req_parts[1]
            headers = {}

            req_parts = http_db_object.request.split(/  |\n/)

            #@note: retrieve HTTP headers values needed later, and the \r\n that indicates the start of the post-data (if any)
            req_parts.each_with_index do |value, index|
              if value.match(/^Content-Length/)
                 @content_length = Integer(req_parts[index].split(/: /)[1])
              end

              if value.match(/^Host/)
                 @host = req_parts[index].split(/: /)[1].split(/:/)[0]
                 @port = req_parts[index].split(/: /)[1].split(/:/)[1]
              end

              if value.eql?("") or value.strip.empty?# this will be the CRLF (before HTTP request body)
                @post_data_index = index
              end
            end

            #@note: add HTTP request headers to an Hash
            req_parts.each_with_index do |value, index|
              if verb.eql?("POST")
                if index > 0 and index < @post_data_index #only add HTTP headers, not the verb/uri/version or post-data
                   header_key = req_parts[index].split(/: /)[0]
                   header_value = req_parts[index].split(/: /)[1]
                   headers[header_key] = header_value
                end
              else
                if index > 0  #only add HTTP headers, not the verb/uri/version
                   header_key = req_parts[index].split(/: /)[0]
                   header_value = req_parts[index].split(/: /)[1]
                   headers[header_key] = header_value
                end
              end
            end

            if @port.nil?
              if uri.match(/^https:/)
                 @port = 443
              else
                 @port = 80
              end
            end

            #POST request
            if not @content_length.nil? and @content_length > 0
              post_data_scliced = req_parts.slice(@post_data_index + 1, req_parts.length)
              @post_data = post_data_scliced.join
              http_request_object = {
                  'id' => http_db_object.id,
                  'method' => verb,
                  'host' => @host.strip,
                  'port' => @port,
                  'data' => @post_data,
                  'uri' => uri,
                  'headers' => headers,
                  'allowCrossDomain' => allow_cross_domain
              }
            else
              #non-POST request (ex. GET)
              http_request_object = {
                  'id' => http_db_object.id,
                  'method' => verb,
                  'host' => @host.strip,
                  'port' => @port,
                  'uri' => uri,
                  'headers' => headers,
                  'allowCrossDomain' => allow_cross_domain
              }
            end

            #@note: parse HTTP headers Hash, adding them to the object that will be used by beef.net.requester.send
            headers.keys.each { |key| http_request_object['headers'][key] = headers[key] }

            http_request_object
          end
        end
      end
    end
  end
end
