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

          BeEF::Core::Models::DNS.each do |record|
            name  = record.name
            type  = BeEF::Extension::DNS::DNS.parse_type(record.type)
            value = record.value

            match(name, type) do |transaction|
              transaction.respond!(value)
            end
          end

          otherwise do |transaction|
            transaction.passthrough!(upstream)
          end
        end
      end
    end

    def add_rule(name, type, value)
      d = BeEF::Core::Models::DNS.new(
        :name  => name,
        :type  => type,
        :value => value
      ).save

      type = BeEF::Extension::DNS::DNS.parse_type(type)

      RubyDNS::stop_server
      run_server
    end

    # XXX Why must this be a class method? As a private instance method,
    #     it throws NoMethodError.
    def self.parse_type(type)
      resolv = 'Resolv::DNS::Resource'

      if type =~ /(A|AAAA|SRV|WKS)/
        resolv += '::IN'
      end

      eval "#{resolv}::#{type}"
    end

  end

end
end
end
