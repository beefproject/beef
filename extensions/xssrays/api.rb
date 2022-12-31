#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Xssrays
      module RegisterHttpHandler
        BeEF::API::Registrar.instance.register(BeEF::Extension::Xssrays::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')

        #
        # Mounts the handlers and REST interface for processing XSS rays
        #
        # @param beef_server [BeEF::Core::Server] HTTP server instance
        #
        def self.mount_handler(beef_server)
          # We register the http handler for the requester.
          # This http handler will retrieve the http responses for all requests
          beef_server.mount('/xssrays', BeEF::Extension::Xssrays::Handler.new)
          # REST API endpoint
          beef_server.mount('/api/xssrays', BeEF::Extension::Xssrays::XssraysRest.new)
        end
      end

      module RegisterPreHookCallback
        BeEF::API::Registrar.instance.register(BeEF::Extension::Xssrays::RegisterPreHookCallback, BeEF::API::Server::Hook, 'pre_hook_send')

        # checks at every polling if there are new scans to be started
        def self.pre_hook_send(hooked_browser, body, _params, _request, _response)
          return if hooked_browser.nil?

          xssrays = BeEF::Extension::Xssrays::API::Scan.new
          xssrays.start_scan(hooked_browser, body)
        end
      end
    end
  end
end
