#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module RubyDNS

  # Behaves exactly the same, minus the output
  def self.run_server(options = {}, &block)
    server = RubyDNS::Server.new(&block)

    options[:listen] ||= [[:udp, "0.0.0.0", 53], [:tcp, "0.0.0.0", 53]]

    EventMachine.run do
      server.fire(:setup)

      options[:listen].each do |spec|
        if spec[0] == :udp
          @signature = EventMachine.open_datagram_socket(spec[1], spec[2], UDPHandler, server)
        elsif spec[0] == :tcp
          @signature = EventMachine.start_server(spec[1], spec[2], TCPHandler, server)
        end
      end

      server.fire(:start)
    end

    server.fire(:stop)
  end

  def self.stop_server
    EventMachine.stop_server(@signature)
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
