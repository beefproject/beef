#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rubygems'
require 'rubydns'

module RubyDNS

  # Behaves exactly the same, except without any output and an added periodic
  # timer that checks for new DNS rules every five seconds
  def self.run_server(options = {}, &block)
    server = RubyDNS::Server.new(&block)

    options[:listen] ||= [[:udp, "0.0.0.0", 53], [:tcp, "0.0.0.0", 53]]

    EventMachine.run do
      server.fire(:setup)

      options[:listen].each do |spec|
        if spec[0] == :udp
          EventMachine.open_datagram_socket(spec[1], spec[2], UDPHandler, server)
        elsif spec[0] == :tcp
          EventMachine.start_server(spec[1], spec[2], TCPHandler, server)
        end
      end

      server.load_rules
      EventMachine.add_periodic_timer(5) { server.check_rules }

      server.fire(:start)
    end

    server.fire(:stop)
  end

  class Transaction

    # Behaves exactly the same, except using debug logger instead of info
    def respond!(*data)
      options = data.last.kind_of?(Hash) ? data.pop : {}
      resource_class = options[:resource_class] || @resource_class
			
      if resource_class == nil
        raise ArgumentError, "Could not instantiate resource #{resource_class}!"
      end
			
      @server.logger.debug "Resource class: #{resource_class.inspect}"
      resource = resource_class.new(*data)
      @server.logger.debug "Resource: #{resource.inspect}"
			
      append!(resource, options)
    end

  end

  class Server

    # Reads current DNS entries in database and adds them as new rules
    def load_rules
      rules = get_rules
      @rule_count = rules.count

      rules.each do |rule|
        match(rule[0], parse_type(rule[1])) do |transaction|
          transaction.respond!(rule[2])
        end
      end
    end

    # Re-loads ruleset if new entries have been added to database
    def check_rules
      load_rules if get_rules.count != @rule_count
    end

    private

    # Returns an AoA where each element is a rule of the form [name, type, value]
    def get_rules
      rules = []

      BeEF::Core::Models::DNS.each do |record|
        name  = record.name
        type  = record.type
        value = record.value

        rules << [name, type, value]
      end

      rules
    end

    # Convenience method for fully-qualifying Resolv::DNS::Resource types
    def parse_type(type)
      resolv = 'Resolv::DNS::Resource'

      if type =~ /(A|AAAA|SRV|WKS)/
        resolv += '::IN'
      end

      eval "#{resolv}::#{type}"
    end

  end

end
