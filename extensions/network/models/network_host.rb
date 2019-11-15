#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores each host identified on the zombie browser's network(s)
      #
      class NetworkHost < ActiveRecord::Base
        attribute :id, :Serial
        attribute :hooked_browser_id, :Text, lazy: false
        attribute :ip, :Text, lazy: false
        attribute :hostname, :String, lazy: false
        attribute :type, :String, lazy: false # proxy, router, gateway, dns, etc
        attribute :os, :String, lazy: false
        attribute :mac, :String, lazy: false
        attribute :lastseen, :String, length: 15
        #
        # Stores a network host in the data store
        #
        def self.add(host = {})
          unless BeEF::Filters.is_valid_hook_session_id?(host[:hooked_browser_id])
            print_error 'Invalid hooked browser session'
            return
          end
          unless BeEF::Filters.is_valid_ip?(host[:ip])
            print_error 'Invalid IP address'
            return
          end

          # save network hosts with private IP addresses only?
          unless BeEF::Filters.is_valid_private_ip?(host[:ip])
            configuration = BeEF::Core::Configuration.instance
            if configuration.get('beef.extension.network.ignore_public_ips') == true
              print_debug "Ignoring network host with public IP address [ip: #{host[:ip]}]"
              return
            end
          end

          # prepare new host for data store
          new_host = {}
          new_host[:hooked_browser_id] = host[:hooked_browser_id]
          new_host[:ip] = host[:ip]
          new_host[:hostname] = host[:hostname] unless host[:hostname].nil?
          new_host[:type] = host[:type] unless host[:type].nil?
          new_host[:os] = host[:os] unless host[:os].nil?
          new_host[:mac] = host[:mac] unless host[:mac].nil?

          # if host already exists in data store with the same details
          # then update lastseen and return
          existing_host = BeEF::Core::Models::NetworkHost.all(new_host)
          unless existing_host.empty?
            existing_host.update(lastseen: Time.new.to_i)
            return
          end

          # store the new network host details
          new_host[:lastseen] = Time.new.to_i
          network_host = BeEF::Core::Models::NetworkHost.new(new_host)
          result = network_host.save
          if result.nil?
            print_error 'Failed to save network host'
            return
          end

          network_host
        end

        #
        # Removes a network host from the data store
        #
        def self.delete(id)
          unless BeEF::Filters.nums_only?(id.to_s)
            print_error 'Failed to remove network host. Invalid host ID.'
            return
          end

          host = BeEF::Core::Models::NetworkHost.get(id.to_i)
          if host.nil?
            print_error "Failed to remove network host [id: #{id}]. Host does not exist."
            return
          end
          host.destroy
        end

        #
        # Convert a Network Host object to JSON
        #
        def to_h
          {
            id: id,
            hooked_browser_id: hooked_browser_id,
            ip: ip,
            hostname: hostname,
            type: type,
            os: os,
            mac: mac,
            lastseen: lastseen
          }
        end
      end
    end
  end
end
