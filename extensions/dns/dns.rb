#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Dns

      # @todo Add option for configuring upstream servers.

      # Provides the core DNS nameserver functionality. The nameserver handles incoming requests
      # using a rule-based system. A list of user-defined rules is used to match against incoming
      # DNS requests. These rules generate a response that is either a resource record or a
      # failure code.
      class Server < RubyDNS::Server

        include Singleton

        def initialize
          super()
          @lock = Mutex.new
        end

        # Entry point for processing incoming DNS requests. Attempts to find a matching rule and
        # sends back its associated response.
        #
        # @param name [String] name of the resource record being looked up
        # @param resource [Resolv::DNS::Resource::IN] query type (e.g. A, CNAME, NS, etc.)
        # @param transaction [RubyDNS::Transaction] internal RubyDNS class detailing DNS question/answer
        def process(name, resource, transaction)
          @lock.synchronize do
            transaction.respond!('1.1.1.1')
          end
        end

      end

    end
  end
end
