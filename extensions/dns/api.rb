#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
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

          # Starts the DNS nameserver at BeEF startup.
          #
          # @param http_hook_server [BeEF::Core::Server] HTTP server instance
          def self.pre_http_start(http_hook_server)
            dns_config = BeEF::Core::Configuration.instance.get('beef.extension.dns')
            dns = BeEF::Extension::Dns::Server.instance

            protocol = dns_config['protocol'].to_sym
            address = dns_config['address']
            port = dns_config['port']
            interfaces = [[protocol, address, port]]

            Thread.new { EventMachine.next_tick { dns.run(:listen => interfaces) } }

            print_info "DNS Server: #{address}:#{port} (#{protocol})"

            # @todo Upstream servers are not yet supported. Uncomment this section when they are.
=begin
            servers = []

            unless dns_config['upstream'].nil?
              dns_config['upstream'].each do |server|
                next if server[1].nil? or server[2].nil?

                if server[0] == 'tcp'
                  servers << ['tcp', server[1], server[2]]
                elsif server[0] == 'udp'
                  servers << ['udp', server[1], server[2]]
                end
              end
            end

            if servers.empty?
              servers << ['tcp', '8.8.8.8', 53]
              servers << ['udp', '8.8.8.8', 53]
            end

            upstream_servers = ''
            servers.each do |server|
              upstream_servers << "Upstream Server: #{server[1]}:#{server[2]} (#{server[0]})\n"
            end

            print_more upstream_servers
=end
          end

          # Mounts the handler for processing DNS RESTful API requests.
          #
          # @param beef_server [BeEF::Core::Server] HTTP server instance
          def self.mount_handler(beef_server)
            # @todo Uncomment when RESTful API is DNS 2.0 compliant.
            #beef_server.mount('/api/dns', BeEF::Extension::Dns::DnsRest.new)
          end

        end

      end
    end
  end
end
