#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Console
      module Banners
        class << self
          attr_accessor :interfaces

          #
          # Prints BeEF's ascii art
          #
          def print_ascii_art
            if File.exist?('core/main/console/beef.ascii')
              File.open('core/main/console/beef.ascii', 'r') do |f|
                while line = f.gets
                  puts line
                end
              end
            end
          end

          #
          # Prints BeEF's welcome message
          #
          def print_welcome_msg
            config = BeEF::Core::Configuration.instance
            version = config.get('beef.version')
            print_info "Browser Exploitation Framework (BeEF) #{version}"
            data = "Twit: @beefproject\n"
            data += "Site: https://beefproject.com\n"
            data += "Blog: http://blog.beefproject.com\n"
            data += "Wiki: https://github.com/beefproject/beef/wiki\n"
            print_more data
            print_info 'Project Creator: ' + 'Wade Alcorn'.red + ' (@WadeAlcorn)'
          end

          #
          # Prints the number of network interfaces beef is operating on.
          # Looks like that:
          #
          # [14:06:48][*] 5 network interfaces were detected.
          #
          def print_network_interfaces_count
            # get the configuration information
            configuration = BeEF::Core::Configuration.instance
            # local host
            beef_host = configuration.local_host

            # create an array of the interfaces the framework is listening on
            if beef_host == '0.0.0.0' # the framework will listen on all interfaces
              interfaces = Socket.ip_address_list.map { |x| x.ip_address if x.ipv4? }
              interfaces.delete_if { |x| x.nil? } # remove if the entry is nill
            else # the framework will listen on only one interface
              interfaces = [beef_host]
            end

            self.interfaces = interfaces

            # output the banner to the console
            print_info "#{interfaces.count} network interfaces were detected."
          end

          #
          # Prints the route to the network interfaces beef has been deployed on.
          # Looks like that:
          #
          # [14:06:48][+] running on network interface: 192.168.255.1
          # [14:06:48]    |   Hook URL: http://192.168.255.1:3000/hook.js
          # [14:06:48]    |   UI URL:   http://192.168.255.1:3000/ui/panel
          # [14:06:48][+] running on network interface: 127.0.0.1
          # [14:06:48]    |   Hook URL: http://127.0.0.1:3000/hook.js
          # [14:06:48]    |   UI URL:   http://127.0.0.1:3000/ui/panel
          #
          def print_network_interfaces_routes
            configuration = BeEF::Core::Configuration.instance
            # local config settings
            proto = configuration.local_proto
            hook_file = configuration.hook_file_path
            admin_ui = configuration.get('beef.extension.admin_ui.enable') ? true : false
            admin_ui_path = configuration.get('beef.extension.admin_ui.base_path')

            # display the hook URL and Admin UI URL on each interface from the interfaces array
            interfaces.map do |host|
              print_info "running on network interface: #{host}"
              port = configuration.local_port
              data = "Hook URL: #{proto}://#{host}:#{port}#{hook_file}\n"
              data += "UI URL:   #{proto}://#{host}:#{port}#{admin_ui_path}/panel\n" if admin_ui
              print_more data
            end

            # display the public hook URL and Admin UI URL
            if configuration.public_enabled?
              print_info 'Public:'
              data = "Hook URL: #{configuration.hook_url}\n"
              data += "UI URL:   #{configuration.beef_url_str}#{admin_ui_path}/panel\n" if admin_ui
              print_more data
            end
          end

          #
          # Print loaded extensions
          #
          def print_loaded_extensions
            extensions = BeEF::Extensions.get_loaded
            print_info "#{extensions.size} extensions enabled:"
            output = ''

            extensions.each do |_key, ext|
              output << "#{ext['name']}\n"
            end

            print_more output
          end

          #
          # Print loaded modules
          #
          def print_loaded_modules
            print_info "#{BeEF::Modules.get_enabled.count} modules enabled."
          end

          #
          # Print WebSocket servers
          #
          def print_websocket_servers
            config = BeEF::Core::Configuration.instance
            ws_poll_timeout = config.get('beef.http.websocket.ws_poll_timeout')
            print_info "Starting WebSocket server ws://#{config.beef_host}:#{config.get('beef.http.websocket.port').to_i} [timer: #{ws_poll_timeout}]"
            if config.get('beef.http.websocket.secure')
              print_info "Starting WebSocketSecure server on wss://[#{config.beef_host}:#{config.get('beef.http.websocket.secure_port').to_i} [timer: #{ws_poll_timeout}]"
            end
          end
        end
      end
    end
  end
end
