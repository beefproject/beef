#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores each open port identified on the zombie browser's network(s)
      #
      class NetworkService

        include DataMapper::Resource
        storage_names[:default] = 'network_service'

        property :id, Serial

        property :hooked_browser_id, Text, :lazy => false
        property :proto, String, :lazy => false
        property :ip, Text, :lazy => false
        property :port, String, :lazy => false
        property :type, String, :lazy => false

        #
        # Stores a network service in the data store
        #
        def self.add(service={})
          (print_error "Invalid hooked browser session"; return) if not BeEF::Filters.is_valid_hook_session_id?(service[:hooked_browser_id])
          (print_error "Invalid IP address"; return) if not BeEF::Filters.is_valid_ip?(service[:ip])
          (print_error "Invalid port"; return) if not BeEF::Filters.is_valid_port?(service[:port])

          # save network services with private IP addresses only?
          unless BeEF::Filters.is_valid_private_ip?(service[:ip])
            configuration = BeEF::Core::Configuration.instance
            if configuration.get("beef.extension.network.ignore_public_ips") == true
              (print_debug "Ignoring network service with public IP address [ip: #{service[:ip]}]"; return)
            end
          end

          # store the returned network host details
          BeEF::Core::Models::NetworkHost.add(
            :hooked_browser_id => service[:hooked_browser_id],
            :ip => service[:ip])

          # prevent duplicates
          return unless BeEF::Core::Models::NetworkService.all(
            :hooked_browser_id => service[:hooked_browser_id],
            :proto => service[:proto],
            :ip => service[:ip],
            :port => service[:port],
            :type => service[:type]).empty?

          # store the returned network service details
          network_service = BeEF::Core::Models::NetworkService.new(
            :hooked_browser_id => service[:hooked_browser_id],
            :proto => service[:proto],
            :ip => service[:ip],
            :port => service[:port],
            :type => service[:type])
          result = network_service.save
          (print_error "Failed to save network service"; return) if result.nil?

          network_service
        end

      end

    end
  end
end
