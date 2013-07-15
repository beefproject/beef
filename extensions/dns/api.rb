#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Dns
module API

  module NameserverHandler

    BeEF::API::Registrar.instance.register(
      BeEF::Extension::Dns::API::NameserverHandler,
      BeEF::API::Server,
      'pre_http_start'
    )

    BeEF::API::Registrar.instance.register(
      BeEF::Extension::Dns::API::NameserverHandler,
      BeEF::API::Server,
      'mount_handler'
    )

    # Begins main DNS server run-loop at BeEF startup
    def self.pre_http_start(http_hook_server)
      dns_config = BeEF::Core::Configuration.instance.get('beef.extension.dns')

      address = dns_config['address']
      port    = dns_config['port']

      dns = BeEF::Extension::Dns::Server.instance
      dns.run_server(address, port)

      print_info "DNS Server: #{address}:#{port}"
    end

    # Mounts handler for processing RESTful API calls
    def self.mount_handler(beef_server)
      beef_server.mount('/api/dns', BeEF::Extension::Dns::DnsRest.new)
    end

  end

end
end
end
end
