#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module DNS
module API

  module NameserverHandler

    BeEF::API::Registrar.instance.register(BeEF::Extension::DNS::API::NameserverHandler,
                                           BeEF::API::Server,
                                           'pre_http_start')

    def self.pre_http_start(http_hook_server)
      config = BeEF::Core::Configuration.instance

      address = config.get('beef.extension.dns.address')
      port    = config.get('beef.extension.dns.port')

      Thread.new { BeEF::Extension::DNS::DNS.new(address, port) }

      print_info "DNS server: #{address}:#{port}"
    end

  end

end
end
end
end
