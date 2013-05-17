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

    # @!method instance
    #   Returns the singleton instance.
    def initialize
      @lock = Mutex.new
      @server = nil
      @next_id = 0
    end

    # Starts the DNS server run-loop.
    #
    # @param address [String] interface address server should run on
    # @param port [Integer] desired server port number
    def run_server(address, port)
      EventMachine::next_tick do
        RubyDNS::run_server(:listen => [[:udp, address, port]]) do
          server = self
          BeEF::Extension::DNS::DNS.instance.instance_eval { @server = server }

          # Pass unmatched queries upstream to root nameservers
          otherwise do |transaction|
            transaction.passthrough!(
              RubyDNS::Resolver.new([[:udp, '8.8.8.8', 53], [:tcp, '8.8.8.8', 53]])
            )
          end
        end
      end
    end

    # Adds a new DNS rule or "resource record". Does nothing if rule is already present.
    #
    # @example Adds an A record for foobar.com with the value 1.2.3.4
    #
    #   dns = BeEF::Extension::DNS::DNS.instance
    #
    #   id = dns.add_rule('foobar.com', Resolv::DNS::Resource::IN::A) do |transaction|
    #     transaction.respond!('1.2.3.4')
    #   end
    #
    # @param pattern [String, Regexp] query pattern to recognize
    # @param type [Resolv::DNS::Resource::IN] resource record type (e.g. A, CNAME, NS, etc.)
    #
    # @yieldparam [RubyDNS::Transaction] details of query question and response
    #
    # @return [Integer] unique id for use with {#remove_rule}
    #
    # @see #remove_rule
    # @see http://rubydoc.info/gems/rubydns/RubyDNS/Transaction
    def add_rule(pattern, type, &block)
      @lock.synchronize do
        @next_id += 1
        @server.match(@next_id, pattern, type, block)
        @next_id
      end
    end

    # Removes the given DNS rule. Any future queries for it will be passed through.
    #
    # @param id [Integer] id returned from {#add_rule}
    # @see #add_rule
    def remove_rule(id)
      @lock.synchronize do
        @server.remove_rule(id)
        @next_id -= 1
      end
    end

    # Returns an AoH representing the entire current DNS ruleset where each element is a
    # hash with the following keys:
    #
    # * <code>:id</code>
    # * <code>:pattern</code>
    # * <code>:type</code>
    # * <code>:block</code>
    #
    # @return [Array<Hash>] DNS ruleset (empty if no rules are currently loaded)
    def get_rules
      @lock.synchronize do
        result = []

        BeEF::Core::Models::DNS::Rule.each do |rule|
          element = {}

          element[:id] = rule.id
          element[:pattern] = rule.pattern
          element[:type] = rule.type
          element[:block] = rule.block

          result << element
        end

        result
      end
    end

  end

end
end
end
