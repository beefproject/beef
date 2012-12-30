#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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

          #  #Thread for websocket-secure
          #  Thread.new {
          #    port = @@config.get("beef.http.websocket.secure_port")
          #    sleep 2 # prevent issues when starting at the same time the TunnelingProxy, Thin and Evented WebSockets
          #    EventMachine.run {
          #
          #      wsopt = {:host => "0.0.0.0", :port => port, :secure => true,
          #               :tls_options => {
          #                   :private_key_file => @root_dir+"/"+@@config.get("beef.http.https.key"),
          #                   :cert_chain_file => @root_dir+"/"+ @@config.get("beef.http.https.cert")
          #               }
          #      }
          #
          #
          #      EventMachine::WebSocket.start(wsopt) do |ws|
          #        begin
          #          print_debug "New WebSocket-secured channel open."
          #          ws.onmessage { |msg|
          #            msg_hash = JSON.parse("#{msg}")
          #            #@note messageHash[result] is Base64 encoded
          #            if (msg_hash["cookie"]!= nil)
          #              print_debug("WebSocket-secured - Browser says helo! WebSocket is running")
          #              #insert new connection in activesocket
          #              @@activeSocket["#{msg_hash["cookie"]}"] = ws
          #              print_debug("WebSocket-secured - activeSocket content [#{@@activeSocket}]")
          #            elsif msg_hash["alive"] != nil
          #              hooked_browser = BeEF::Core::Models::HookedBrowser.first(:session => msg_hash["alive"])
          #              unless hooked_browser.nil?
          #                hooked_browser.lastseen = Time.new.to_i
          #                hooked_browser.count!
          #                hooked_browser.save
          #
          #                #Check if new modules need to be sent
          #                zombie_commands = BeEF::Core::Models::Command.all(:hooked_browser_id => hooked_browser.id, :instructions_sent => false)
          #                zombie_commands.each { |command| add_command_instructions(command, hooked_browser) }
          #
          #                #@todo antisnatchor:
          #                #@todo - re-use the pre_hook_send callback mechanisms to have a generic check for multipl extensions
          #                #Check if new forged requests need to be sent (Requester/TunnelingProxy)
          #                dhook = BeEF::Extension::Requester::API::Hook.new
          #                dhook.requester_run(hooked_browser, '')
          #
          #                #Check if new XssRays scan need to be started
          #                xssrays = BeEF::Extension::Xssrays::API::Scan.new
          #                xssrays.start_scan(hooked_browser, '')
          #              end
          #            else
          #              #json recv is a cmd response decode and send all to
          #              #we have to call dynamicreconstructor handler camp must be websocket
          #              #print_debug("Received from WebSocket #{messageHash}")
          #              execute(msg_hash)
          #            end
          #          }
          #        rescue Exception => e
          #          print_error "WebSocket-secured error: #{e}"
          #        end
          #      end
          #    }
          #
          #  }
          #
          ##Thread for websocket
          #Thread.new {
          #  port = @@config.get("beef.http.websocket.port")
          #  sleep 2 # prevent issues when starting at the same time the TunnelingProxy, Thin and Evented WebSockets
          #  EventMachine.run {
          #
          #    wsopt = {:host => "0.0.0.0", :port => port}
          #
          #
          #    EventMachine::WebSocket.start(wsopt) do |ws|
          #      begin
          #        print_debug "New WebSocket channel open."
          #        ws.onmessage { |msg|
          #          msg_hash = JSON.parse("#{msg}")
          #          #@note messageHash[result] is Base64 encoded
          #          if (msg_hash["cookie"]!= nil)
          #            print_debug("WebSocket - Browser says helo! WebSocket is running")
          #            #insert new connection in activesocket
          #            @@activeSocket["#{msg_hash["cookie"]}"] = ws
          #            print_debug("WebSocket - activeSocket content [#{@@activeSocket}]")
          #          elsif msg_hash["alive"] != nil
          #            hooked_browser = BeEF::Core::Models::HookedBrowser.first(:session => msg_hash["alive"])
          #            unless hooked_browser.nil?
          #              hooked_browser.lastseen = Time.new.to_i
          #              hooked_browser.count!
          #              hooked_browser.save
          #
          #              #Check if new modules need to be sent
          #              zombie_commands = BeEF::Core::Models::Command.all(:hooked_browser_id => hooked_browser.id, :instructions_sent => false)
          #              zombie_commands.each { |command| add_command_instructions(command, hooked_browser) }
          #
          #              #@todo antisnatchor:
          #              #@todo - re-use the pre_hook_send callback mechanisms to have a generic check for multipl extensions
          #              #Check if new forged requests need to be sent (Requester/TunnelingProxy)
          #              dhook = BeEF::Extension::Requester::API::Hook.new
          #              dhook.requester_run(hooked_browser, '')
          #
          #              #Check if new XssRays scan need to be started
          #              xssrays = BeEF::Extension::Xssrays::API::Scan.new
          #              xssrays.start_scan(hooked_browser, '')
          #            end
          #          else
          #            #json recv is a cmd response decode and send all to
          #            #we have to call dynamicreconstructor handler camp must be websocket
          #            #print_debug("Received from WebSocket #{messageHash}")
          #            execute(msg_hash)
          #          end
          #        }
          #      rescue Exception => e
          #        print_error "WebSocket error: #{e}"
          #      end
          #    end
          #  }
          #}


        end

        def start_websocket_server(ws_options, secure)
          Thread.new {
            sleep 2 # prevent issues when starting at the same time the TunnelingProxy, Thin and Evented WebSockets
            EventMachine.run {
              EventMachine::WebSocket.start(ws_options) do |ws|
                begin
                  secure ? print_debug("New WebSocketSecure channel open.") : print_debug("New WebSocket channel open.")
                  ws.onmessage { |msg|
                    msg_hash = JSON.parse("#{msg}")
                    #@note messageHash[result] is Base64 encoded
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
                  }
                rescue Exception => e
                  print_error "WebSocket error: #{e}"
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

        BeEF::Core::Handlers::Commands
        #call the handler for websocket cmd response
        #@param [Hash] data contains the answer of a command
        def execute (data)
          command_results=Hash.new
          command_results["data"]=Base64.decode64(data["result"])
          command_results["data"].force_encoding('UTF-8')
          hooked_browser = data["bh"]
          (print_error "BeEFhook is invalid"; return) if not BeEF::Filters.is_valid_hook_session_id?(hooked_browser)
          (print_error "command_id is invalid"; return) if not BeEF::Filters.is_valid_command_id?(data["cid"])
          (print_error "command name is empty"; return) if data["handler"].empty?
          (print_error "command results are empty"; return) if command_results.empty?
          handler = data["handler"]
          if handler.match(/command/)
            BeEF::Core::Models::Command.save_result(hooked_browser, data["cid"],
                                                    @@config.get("beef.module.#{handler.gsub("/command/", "").gsub(".js", "")}.name"), command_results)
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
