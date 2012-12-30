#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Customhook
  
  module RegisterHttpHandlers
    
    BeEF::API::Registrar.instance.register(BeEF::Extension::Customhook::RegisterHttpHandlers, BeEF::API::Server, 'mount_handler')
    BeEF::API::Registrar.instance.register(BeEF::Extension::Customhook::RegisterHttpHandlers, BeEF::API::Server, 'pre_http_start')
    
    def self.mount_handler(beef_server)
      configuration = BeEF::Core::Configuration.instance
      beef_server.mount(configuration.get("beef.extension.customhook.customhook_path"), BeEF::Extension::Customhook::Handler.new)
    end

    def self.pre_http_start(beef_server)
      configuration = BeEF::Core::Configuration.instance
      print_success "Successfully mounted a custom hook point"
      print_more "Mount Point: #{configuration.get('beef.extension.customhook.customhook_path')}\nLoading iFrame: #{configuration.get('beef.extension.customhook.customhook_target')}\n"
    end
  end
end
end
end
