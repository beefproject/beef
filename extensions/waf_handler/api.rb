#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Waf_handler
module API

  module WafHandler
	BeEF::API::Registrar.instance.register(
            BeEF::Extension::Waf_handler::API::WafHandler,
            BeEF::API::Server,
            'mount_handler'
	)
    

    def self.mount_handler(beef_server)
          beef_server.mount('/waf', BeEF::Extension::Waf_handler::ServerHandler.new)
        print_info "WAF Handler Server: /waf" 
    end

  end

end
end
end
end
