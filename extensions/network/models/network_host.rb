#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores each host identified on the zombie browser's network(s)
      #
      class NetworkHost < BeEF::Core::Model
        belongs_to :hooked_browser

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
          new_host[:ntype] = host[:ntype] unless host[:ntype].nil?
          new_host[:os] = host[:os] unless host[:os].nil?
          new_host[:mac] = host[:mac] unless host[:mac].nil?

          # if host already exists in data store with the same details
          # then update lastseen and return
          existing_host = BeEF::Core::Models::NetworkHost.where(hooked_browser_id: new_host[:hooked_browser_id], ip: new_host[:ip]).limit(1)
          unless existing_host.empty?
            existing_host = existing_host.first
            existing_host.lastseen = Time.new.to_i
            existing_host.save!
            return
          end

          # store the new network host details
          new_host[:lastseen] = Time.new.to_i
          network_host = BeEF::Core::Models::NetworkHost.new(new_host)
          if network_host.save
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

          host = BeEF::Core::Models::NetworkHost.find(id.to_i)
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
            ntype: ntype,
            os: os,
            mac: mac,
            lastseen: lastseen
          }
        end
      end
    end
  end
end
