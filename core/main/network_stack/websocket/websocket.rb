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
module BeEF
  module Core
    module Websocket
      require 'singleton'

      class Websocket
       # require 'singleton'
        #include Singleton
        #all hooked browser
        include Singleton
       @@activeSocket= Hash.new #empty at begin


        def initialize
          print_info("/n In activesocket we have #{@@activeSocket}")
          config = BeEF::Core::Configuration.instance
          port = config.get("beef.http.websocket.port")
          secure = config.get("beef.http.websocket.secure")
          #todo antisnatchor: start websocket secure if beef.http.websocket.secure == true
          server = WebSocketServer.new :accepted_domains => "127.0.0.1",
                                       :port => port
          print_info("Started WebSocket server: port [#{port.to_s}], secure [#{secure.to_s}]")

          Thread.new {
            server.run() do |ws|
              #@TODO debug print the path and who request for hooked browser mapping
              print_info("Path requested #{ws.path} Origins #{ws.origin}")
              if ws.path == "/"
                ws.handshake() #accept and connect

                while true
                  #command interpretation
                  message=ws.receive()

                  if(/BEEFHOOK=/.match(message))
                    print_info("Browser #{ws.origin} says helo! ws is running")
                    #insert new connection in activesocket
                    @@activeSocket["#{message.split(/BEEFHOOK=/)}"] = ws
                    print_debug("In activesocket we have #{@@activeSocket}")
                  end
                end
              end
            end
          }
        end
        #@note used in command.rd return nill if browser is not in list else giveback websocket
        def getsocket (browser_id)
          @@activeSocket[browser_id]
        end
        #@note send a function to hooked and ws browser
        def sent (fn ,browser_id )
             @@activeSocket[browser_id].send(fn)
        end

      end
    end
  end
end
