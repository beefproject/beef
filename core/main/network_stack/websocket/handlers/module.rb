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


      def initialize


        print_info("Inside")
        #load the library
        $LOAD_PATH << File.dirname(__FILE__) + "../lib"
        require "web_socket"
        server = WebSocketServer.new("localhost", 6666) #we get host and port how
        server.run() do |ws|
          #@TODO debug print the path and who request for hooked browser mapping
          print_info("Path requested #{ws.path} Originis #{ws.origin}")
          if ws.path == "/"
            ws.handshake() #accept and connect

            while true
              #command interpretation
              message=ws.receve()

              if (message!="helo")
                #module return value case
              else
                print_info("Browser #{ws.origin} says helo! ws is running")
              end

            end
          end


        end


      end
    end
  end
end
