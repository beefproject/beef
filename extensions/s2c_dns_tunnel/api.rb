#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module ServerClientDnsTunnel
      module API

        module ServerClientDnsTunnelHandler

          BeEF::API::Registrar.instance.register( BeEF::Extension::ServerClientDnsTunnel::API::ServerClientDnsTunnelHandler, 
                          BeEF::API::Server, 'pre_http_start' )
          BeEF::API::Registrar.instance.register( BeEF::Extension::ServerClientDnsTunnel::API::ServerClientDnsTunnelHandler, 
                          BeEF::API::Server, 'mount_handler' )

          # Starts the S2C DNS Tunnel server at BeEF startup.
          # @param http_hook_server [BeEF::Core::Server] HTTP server instance
          def self.pre_http_start(http_hook_server)

            configuration = BeEF::Core::Configuration.instance
            zone = configuration.get('beef.extension.s2c_dns_tunnel.zone')
            raise ArgumentError,'zone name is undefined' unless zone.to_s != ""

            # if listen parameter is not defined in the config.yaml then interface with the highest BeEF's IP-address will be choosen
            listen = configuration.get('beef.extension.s2c_dns_tunnel.listen')
            Socket.ip_address_list.map {|x| listen = x.ip_address if x.ipv4?} if listen.to_s.empty?

            port = 53
            protocol = :udp
            interfaces = [[protocol, listen, port]]
            dns = BeEF::Extension::ServerClientDnsTunnel::Server.instance
            dns.run(:listen => interfaces, :zone => zone)

            print_info "Server-to-Client DNS Tunnel Server: #{listen}:#{port} (#{protocol})"
            info = ''
            info += "Zone: " + zone + "\n"
            print_more info

          end

          # Mounts the handler for processing HTTP image requests.
          # @param beef_server [BeEF::Core::Server] HTTP server instance
          def self.mount_handler(beef_server)
            configuration = BeEF::Core::Configuration.instance
            zone = configuration.get('beef.extension.s2c_dns_tunnel.zone')
            beef_server.mount('/tiles', BeEF::Extension::ServerClientDnsTunnel::Httpd.new(zone))
          end

        end

      end
    end
  end
end
