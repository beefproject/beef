#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#@todo STOP POLLING
module BeEF
  module Core
    module Websocket
      require 'singleton'
      require 'json'
      require 'base64'
      class Websocket
        include Singleton
        include BeEF::Core::Handlers::Modules::Command
        # @note obtain dynamic mount points from HttpHookServer
        MOUNTS = BeEF::Core::Server.instance.mounts
        @@activeSocket= Hash.new #empty at begin
        @@lastalive= Hash.new
        @@config = BeEF::Core::Configuration.instance
        def initialize
          port = @@config.get("beef.http.websocket.port")
          secure = @@config.get("beef.http.websocket.secure")
          #todo antisnatchor: start websocket secure if beef.http.websocket.secure == true
          server = WebSocketServer.new :accepted_domains => "127.0.0.1",
                                       :port => port
          print_info("Started WebSocket server: port [#{port.to_s}], secure [#{secure.to_s}]")

          Thread.new {
            server.run() do |ws|
              begin
                print_debug("Path requested #{ws.path} Origins #{ws.origin}")
                  if ws.path == "/"
                    ws.handshake() #accept and connect
                    while true
                      #command interpretation
                      message = ws.receive()
                      messageHash = JSON.parse("#{message}")
                      #@note messageHash[result] is Base64 encoded
                      if (messageHash["cookie"]!= nil)
                        print_info("Browser #{ws.origin} says helo! WebSocket is running")
                        #insert new connection in activesocket
                        @@activeSocket["#{messageHash["cookie"]}"] = ws
                        print_debug("In activesocket we have #{@@activeSocket}")
                      elsif messageHash["alive"] != nil
                        hooked_browser = BeEF::Core::Models::HookedBrowser.first(:session => messageHash["alive"])
                        hooked_browser.lastseen = Time.new.to_i
                        hooked_browser.count!
                        hooked_browser.save
                        zombie_commands = BeEF::Core::Models::Command.all(:hooked_browser_id => hooked_browser.id, :instructions_sent => false)
                        zombie_commands.each{|command| add_command_instructions(command, hooked_browser)}
                      else
                        #json recv is a cmd response decode and send all to
                        #we have to call dynamicreconstructor handler camp must be websocket
                        #print_debug("Received from WebSocket #{messageHash}")
                        execute(messageHash)
                      end
                    end
                  end
              rescue Exception => e
                print_error "Hooked browser from origin #{ws.origin} abruptly disconnected. #{e}"
                 end
            end
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
        def sent (fn, session)
          @@activeSocket[session].send(fn)
        end

        BeEF::Core::Handlers::Commands
        #call the handler for websocket cmd response
        #@param [Hash] data contains the answer of a command
        def execute (data)
          command_results=Hash.new
          command_results["data"]=Base64.decode64(data["result"])
          command_results["data"].force_encoding('UTF-8')
          (print_error "BeEFhook is invalid"; return) if not BeEF::Filters.is_valid_hook_session_id?(data["bh"])
          (print_error "command_id is invalid"; return) if not BeEF::Filters.is_valid_command_id?(data["cid"])
          (print_error "command name is empty"; return) if data["handler"].empty?
          (print_error "command results are empty"; return) if command_results.empty?
          BeEF::Core::Models::Command.save_result(data["bh"], data["cid"],
            @@config.get("beef.module.#{data["handler"].gsub("/command/","").gsub(".js","")}.name"), command_results)
        end


      end
    end
  end
end
