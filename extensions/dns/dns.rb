#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module DNS

  class DNS

    include Singleton

    UPSTREAM = RubyDNS::Resolver.new([[:udp, '8.8.8.8', 53], [:tcp, '8.8.8.8', 53]])

    #def initialize(address, port)
      #@address = address
      #@port = port

      #EventMachine::next_tick { run_server }
    #end

    def run_server(address, port)
      EventMachine::next_tick do
        RubyDNS::run_server(:listen => [[:udp, address, port]]) do
          otherwise do |transaction|
            transaction.passthrough!(UPSTREAM)
          end
        end
      end
    end

  end

end
end
end
