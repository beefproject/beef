#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Requester
      module RegisterHttpHandler
        BeEF::API::Registrar.instance.register(BeEF::Extension::Requester::RegisterHttpHandler, BeEF::API::Server, 'mount_handler')

        def self.mount_handler(beef_server)
          beef_server.mount('/requester', BeEF::Extension::Requester::Handler)
          beef_server.mount('/api/requester', BeEF::Extension::Requester::RequesterRest.new)
        end
      end

      module RegisterPreHookCallback
        BeEF::API::Registrar.instance.register(BeEF::Extension::Requester::RegisterPreHookCallback, BeEF::API::Server::Hook, 'pre_hook_send')

        def self.pre_hook_send(hooked_browser, body, _params, _request, _response)
          dhook = BeEF::Extension::Requester::API::Hook.new
          dhook.requester_run(hooked_browser, body)
        end
      end
    end
  end
end
