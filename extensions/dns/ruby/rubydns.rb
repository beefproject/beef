#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rubygems'
require 'rubydns'

module RubyDNS

  # Behaves exactly the same, except without any logger output
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

      server.fire(:start)
    end

    server.fire(:stop)
  end

  class Server

    attr_accessor :rules

    class Rule

      attr_accessor :id

      # Now uses an 'id' parameter to uniquely identify rules
      def initialize(id, pattern, callback)
        @id = id
        @pattern  = pattern
        @callback = callback
      end

    end

    # Now uses an 'id' parameter to uniquely identify rules
    def match(id, *pattern, block)
      @rules << Rule.new(id, pattern, block)
    end

    # New method that removes a rule given its id
    def remove_rule(id)
      @rules.delete_if { |rule| rule.id == id }
    end

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

end
