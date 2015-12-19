#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores each host identified on the zombie browser's network(s)
      #
      class NetworkHost

        include DataMapper::Resource
        storage_names[:default] = 'network_host'

        property :id, Serial

        property :hooked_browser_id, Text, :lazy => false
        property :ip, Text, :lazy => false
        property :hostname, String, :lazy => false
        property :type, String, :lazy => false # proxy, router, gateway, dns, etc
        property :os, String, :lazy => false
        property :mac, String, :lazy => false
        property :lastseen, String, :length => 15

        #
        # Stores a network host in the data store
        #
        def self.add(host={})
          (print_error "Invalid hooked browser session"; return) unless BeEF::Filters.is_valid_hook_session_id?(host[:hooked_browser_id])
          (print_error "Invalid IP address"; return) unless BeEF::Filters.is_valid_ip?(host[:ip])

          # save network hosts with private IP addresses only?
          unless BeEF::Filters.is_valid_private_ip?(host[:ip])
            configuration = BeEF::Core::Configuration.instance
            if configuration.get("beef.extension.network.ignore_public_ips") == true
              (print_debug "Ignoring network host with public IP address [ip: #{host[:ip]}]"; return)
            end
          end

          # update lastseen
          BeEF::Core::Models::NetworkHost.all(
            :hooked_browser_id => host[:hooked_browser_id],
            :ip => host[:ip]).update( :lastseen => Time.now )

          # prevent duplicates
          return unless BeEF::Core::Models::NetworkHost.all(
            :hooked_browser_id => host[:hooked_browser_id],
            :ip => host[:ip],
            :hostname => host[:hostname],
            :type => host[:type],
            :os => host[:os],
            :mac => host[:mac]).empty?

          # store the returned network host details
          network_host = BeEF::Core::Models::NetworkHost.new(
            :hooked_browser_id => host[:hooked_browser_id],
            :ip => host[:ip],
            :hostname => host[:hostname],
            :type => host[:type],
            :os => host[:os],
            :mac => host[:mac],
            :lastseen => Time.now)
          result = network_host.save
          (print_error "Failed to save network host"; return) if result.nil?

          network_host
        end

        #
        # Removes a network host from the data store
        #
        def self.delete(id)
          (print_error "Failed to remove network host. Invalid host ID."; return) if id.to_s !~ /\A\d+\z/
          host = BeEF::Core::Models::NetworkHost.get(id.to_i)
          (print_error "Failed to remove network host [id: #{id}]. Host does not exist."; return) if host.nil?
          host.destroy
        end

      end

    end
  end
end
