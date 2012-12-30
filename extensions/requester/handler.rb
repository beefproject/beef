#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Requester

      #
      # The http handler that manages the Requester.
      #
      class Handler

        H = BeEF::Core::Models::Http
        Z = BeEF::Core::Models::HookedBrowser

        def initialize(data)
          @data = data
          setup()
        end

        def setup()

          # validates the hook token
          beef_hook = @data['beefhook'] || nil
          (print_error "beefhook is null";return) if beef_hook.nil?

          # validates the request id
          request_id = @data['cid'] || nil
          (print_error "Original request id (command id) is null";return) if request_id.nil?

          # validates that a hooked browser with the beef_hook token exists in the db
          zombie_db = Z.first(:session => beef_hook) || nil
          (print_error "Invalid beefhook id: the hooked browser cannot be found in the database";return) if zombie_db.nil?

          # validates that we have such a http request saved in the db
          http_db = H.first(:id => request_id.to_i, :hooked_browser_id => zombie_db.id) || nil
          (print_error "Invalid http_db: no such request found in the database";return) if http_db.nil?

          # validates that the http request has not been run before
          (print_error  "This http request has been saved before";return) if http_db.has_ran.eql? "complete"

          # validates the response code
          response_code = @data['results']['response_status_code'] || nil
          (print_error "Http response code is null";return) if response_code.nil?

          # save the results in the database
          http_db.response_headers = @data['results']['response_headers']
          http_db.response_status_code = @data['results']['response_status_code']
          http_db.response_status_text = @data['results']['response_status_text']
          http_db.response_port_status = @data['results']['response_port_status']
          http_db.response_data = @data['results']['response_data']
          http_db.response_date = Time.now
          http_db.has_ran = "complete"

          # Store images as binary
          # see issue https://github.com/beefproject/beef/issues/449
          if http_db.response_headers =~ /Content-Type: image/
            http_db.response_data = http_db.response_data.unpack('a*')
          end
          http_db.save
        end
      end
    end
  end
end
