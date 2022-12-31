#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores each open port identified on the zombie browser's network(s)
      #
      class NetworkService < BeEF::Core::Model
        belongs_to :hooked_browser

        #
        # Stores a network service in the data store
        #
        def self.add(service = {})
          unless BeEF::Filters.is_valid_hook_session_id?(service[:hooked_browser_id])
            print_error 'Invalid hooked browser session'
            return
          end
          unless BeEF::Filters.is_valid_ip?(service[:ip])
            print_error 'Invalid IP address'
            return
          end
          unless BeEF::Filters.is_valid_port?(service[:port])
            print_error 'Invalid port'
            return
          end

          # save network services with private IP addresses only?
          unless BeEF::Filters.is_valid_private_ip?(service[:ip])
            configuration = BeEF::Core::Configuration.instance
            if configuration.get('beef.extension.network.ignore_public_ips') == true
              print_debug "Ignoring network service with public IP address [ip: #{service[:ip]}]"
              return
            end
          end

          # store the returned network host details
          BeEF::Core::Models::NetworkHost.create(
            hooked_browser_id: service[:hooked_browser_id],
            ip: service[:ip]
          )

          # prevent duplicates
          total = BeEF::Core::Models::NetworkService.where(
            hooked_browser_id: service[:hooked_browser_id],
            proto: service[:proto],
            ip: service[:ip],
            port: service[:port],
            ntype: service[:ntype]
          ).length
          return if total.positive?

          # store the returned network service details
          network_service = BeEF::Core::Models::NetworkService.new(
            hooked_browser_id: service[:hooked_browser_id],
            proto: service[:proto],
            ip: service[:ip],
            port: service[:port],
            ntype: service[:ntype]
          )
          if network_service.save
            print_error 'Failed to save network service'
            return
          end

          network_service
        end

        # Convert a Network Service object to JSON
        def to_h
          {
            id: id,
            hooked_browser_id: hooked_browser_id,
            proto: proto,
            ip: ip,
            port: port,
            ntype: ntype
          }
        end
      end
    end
  end
end
