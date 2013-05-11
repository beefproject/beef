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

    def run_server(address, port)
      EventMachine::next_tick do
        RubyDNS::run_server(:listen => [[:udp, address, port]]) do
          upstream = RubyDNS::Resolver.new([[:udp, '8.8.8.8', 53], [:tcp, '8.8.8.8', 53]])

          otherwise do |transaction|
            transaction.passthrough!(upstream)
          end
        end
      end
    end

    def add_rule(name, type, value)
      catch(:match) do
        BeEF::Core::Models::DNS.each do |rule|
          n = rule.name
          t = rule.type
          v = rule.value

          throw :match if [n, t, v] == [name, type, value]
        end

        BeEF::Core::Models::DNS.create(
          :name  => name,
          :type  => type,
          :value => value
        )
      end
    end

  end

end
end
end
