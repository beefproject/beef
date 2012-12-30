#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
