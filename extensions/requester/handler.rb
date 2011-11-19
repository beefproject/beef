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

      #
      # The http handler that manages the Requester.
      #
      class Handler < WEBrick::HTTPServlet::AbstractServlet
        attr_reader :guard

        H = BeEF::Core::Models::Http
        Z = BeEF::Core::Models::HookedBrowser

        #
        # Class constructor
        #
        def initialize(data)
          # we set up a mutex
          @guard = Mutex.new
          @data = data
          setup()
        end

        def setup()

          # validates the hook token
          beef_hook = @data['beefhook'] || nil
          raise WEBrick::HTTPStatus::BadRequest, "beefhook is null" if beef_hook.nil?

          # validates the request id
          request_id = @data['cid'] || nil
          raise WEBrick::HTTPStatus::BadRequest, "Original request id (command id) is null" if request_id.nil?

          # validates that a hooked browser with the beef_hook token exists in the db
          zombie_db = Z.first(:session => beef_hook) || nil
          raise WEBrick::HTTPStatus::BadRequest, "Invalid beefhook id: the hooked browser cannot be found in the database" if zombie_db.nil?

          # validates that we have such a http request saved in the db
          http_db = H.first(:id => request_id.to_i, :hooked_browser_id => zombie_db.id) || nil
          raise WEBrick::HTTPStatus::BadRequest, "Invalid http_db: no such request found in the database" if http_db.nil?

          # validates that the http request has not be ran before
          raise WEBrick::HTTPStatus::BadRequest, "This http request has been saved before" if http_db.has_ran.eql? "complete"

          # validates the response code
          response_code = @data['results']['response_status_code'] || nil
          raise WEBrick::HTTPStatus::BadRequest, "Http response code is null" if response_code.nil?

          # save the results in the database
          http_db.response_headers = @data['results']['response_headers']
          http_db.response_status_code = @data['results']['response_status_code']
          http_db.response_status_text = @data['results']['response_status_text']
          http_db.response_port_status = @data['results']['response_port_status']
          http_db.response_data = @data['results']['response_data']
          http_db.response_date = Time.now
          http_db.has_ran = "complete"

          # Store images as binary
          # see issue http://code.google.com/p/beef/issues/detail?id=368
          if http_db.response_headers =~ /Content-Type: image/
            http_db.response_data = http_db.response_data.unpack('a*')
          end
          http_db.save
        end
      end
    end
  end
end
