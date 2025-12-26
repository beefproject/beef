#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
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
          def self.pre_http_start(_http_hook_server)
            servers, interfaces, address, port, protocol, upstream_servers = get_dns_config # get the DNS configuration

            # Start the DNS server
            dns = BeEF::Extension::Dns::Server.instance
            dns.run(upstream: servers, listen: interfaces)
          end

          def self.print_dns_info
            servers, interfaces, address, port, protocol, upstream_servers = get_dns_config # get the DNS configuration

            # Print the DNS server information
            print_info "DNS Server: #{address}:#{port} (#{protocol})"
            print_more upstream_servers unless upstream_servers.empty?
          end

          def self.get_dns_config
            dns_config = BeEF::Core::Configuration.instance.get('beef.extension.dns')

            protocol = begin
              dns_config['protocol'].to_sym
            rescue StandardError
              :udp
            end
            address = dns_config['address'] || '127.0.0.1'
            port = dns_config['port'] || 5300
            interfaces = [[protocol, address, port]]

            servers = []
            upstream_servers = ''

            unless dns_config['upstream'].nil? || dns_config['upstream'].empty?
              dns_config['upstream'].each do |server|
                up_protocol = server[0].downcase
                up_address = server[1]
                up_port = server[2]

                next if [up_protocol, up_address, up_port].include?(nil)

                servers << [up_protocol.to_sym, up_address, up_port] if up_protocol =~ /^(tcp|udp)$/
                upstream_servers << "Upstream Server: #{up_address}:#{up_port} (#{up_protocol})\n"
              end
            end

            return servers, interfaces, address, port, protocol, upstream_servers
          end

          # Mounts the handler for processing DNS RESTful API requests.
          #
          # @param beef_server [BeEF::Core::Server] HTTP server instance
          def self.mount_handler(beef_server)
            beef_server.mount('/api/dns', BeEF::Extension::Dns::DnsRest.new)
          end
        end
      end
    end
  end
end
