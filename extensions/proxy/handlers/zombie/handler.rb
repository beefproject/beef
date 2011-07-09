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
module Proxy
module Handlers
module Zombie

  class Handler

    attr_reader :guard
    @response = nil
    H = BeEF::Core::Models::Http

    # This function will forward requests to the target and 
    # the browser will perform the request. Then the results
    # will be sent back.
    def forward_request(hooked_browser_id, req, res)

      # Append port to domain string if not 80 or 443
      if req.port != 80 or req.port != 443
        domain = req.host.to_s + ':' + req.port.to_s
      else
        domain = req.host.to_s
      end
      
      # Saves the new HTTP request to the db for processing by browser.
      # IDs are created and incremented automatically by DataMapper.
      http = H.new(
        :request => req,
        :method => req.request_method.to_s,
        :domain => domain,
        :path => req.path.to_s,
        :request_date => Time.now,
        :hooked_browser_id => hooked_browser_id
      )
      http.save

      # Starts a new thread scoped to this Handler instance, in order to minimize performance degradation
      # while waiting for the HTTP response to be stored in the db.
      print_info("[PROXY] Thread started in order to process request ##{http.id} to [#{req.path.to_s}] on domain [#{domain}]")
      @response_thread = Thread.new do
        while !H.first(:id => http.id).has_ran
          sleep 0.5
        end
        @response = H.first(:id => http.id)
      end

      @response_thread.join
      print_info("[PROXY] Response for request ##{http.id} to [#{req.path.to_s}] on domain [#{domain}] correctly processed")

      res.body = @response['response_data']

      # set the original response status code
      res.status = @response['response_status_code']

      headers = @response['response_headers']
      #print_debug("====== original HTTP response headers =======\n#{headers}")

      # The following is needed to forward back some of the original HTTP response headers obtained via XHR calls.
      # Original XHR response headers are stored in extension_requester_http table (response_headers column),
      # but we are forwarding back only some of them (Server, X-.. - like X-Powered-By -, Content-Type, ... ).
      # Some of the original response headers need to be removed, like encoding and cache related: for example
      # about encoding, the original response headers says that the content-length is 1000 as the response is gzipped,
      # but the final content-length forwarded back by the proxy is clearly bigger. Date header follows the same way.
      headers_hash = Hash.new
      if(res.status != -1 && res.status != 0)
         headers.each_line do |line|
           # stripping the Encoding, Cache and other headers
           if line.split(': ')[0] != "Content-Encoding" &&
               line.split(': ')[0] != "Content-Length" &&
               line.split(': ')[0] != "Keep-Alive" &&
               line.split(': ')[0] != "Cache-Control" &&
               line.split(': ')[0] != "Vary" &&
               line.split(': ')[0] != "Pragma" &&
               line.split(': ')[0] != "Connection" &&
               line.split(': ')[0] != "Expires" &&
               line.split(': ')[0] != "Accept-Ranges" &&
               line.split(': ')[0] != "Date"
             headers_hash[line.split(': ')[0]] = line.split(': ')[1].gsub!(/[\n]+/,"")
           end
         end

         # note: override_headers is a (new) method of WebRick::HTTPResponse (the BeEF patch one: core\ruby\patches\webrick\httpresponse.rb)
         res.override_headers(headers_hash)
      end
      res
    end
  end
end
end
end
end
end