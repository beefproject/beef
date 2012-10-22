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
  module Extension
    module Ipec
      class JunkCalculator
        include Singleton

        def initialize
           @binded_sockets = {}
           @host = BeEF::Core::Configuration.instance.get('beef.http.host')
        end

        def bind_junk_calculator(name)
          port = 2000
          #todo add binded ports to @binded_sockets. Increase +1 port number if already binded
          #if @binded_sockets[port] != nil
          #else
          #end
          BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_socket(name, @host, port)
          @binded_sockets[name] = port

        end
      end
    end
  end
end
