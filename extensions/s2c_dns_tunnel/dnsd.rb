#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module ServerClientDnsTunnel

      class RubyDNS::Transaction

        def fail!(rcode,domain)
          append_question!

          if rcode.kind_of? Symbol
            @answer.rcode = Resolv::DNS::RCode.const_get(rcode)
          else
            @answer.rcode = rcode.to_i
          end

          if rcode == :NXDomain
            @answer.aa = 1
            soa = Resolv::DNS::Resource::IN::SOA.new(Resolv::DNS::Name.create("ns." + domain),
                                                     Resolv::DNS::Name.create("hostmaster." + domain),
                                                     Time.now.strftime("%Y%m%d%H").to_i,86400,7200,3600000,172800
                                                    )
            @answer.add_authority(name,3600,soa)
          end
        end
      end

      class Server < RubyDNS::Server

        include Singleton

        attr_accessor :messages

        def initialize()
          super()
          @lock = Mutex.new
        end

        # Starts the custom DNS server.
        #
        # @param options [Hash] server configuration options
        # @option options [Array<Array>] :zone - zone manged by BeEF DNS server for data exfiltration
        # @option options [Array<Array>] :listen - local interfaces to listen on
        def run(options = {})
          @lock.synchronize do
            Thread.new do
              EventMachine.next_tick do
                listen = options[:listen] || nil
                super(:listen => listen)

                @selfip   = options[:listen][0][1]
                @zone   = options[:zone]
                @messages = {}

                end
            end
          end
        end

        # Entry point for processing incoming DNS requests.
        #
        # @param name [String] name of the resource record being looked up
        # @param resource [Resolv::DNS::Resource::IN] query type (e.g. A, CNAME, NS, etc.)
        # @param transaction [RubyDNS::Transaction] internal RubyDNS class detailing DNS question/answer
        def process(name,resource,transaction)  
          @lock.synchronize do
            print_debug "Received DNS request (name: #{name} type: #{format_resource(resource)})"
            if format_resource(resource) != 'A' or not name.match(/#{@zone}$/)
              transaction.fail!(:Refused,@zone) 
              return
            end

            # Parce query name in accordance with Active Directory SRV resource records
            cid = name.split('.')[2].split('-')[2].to_i
            bit = name.split('.')[2].split('-')[3].to_i(16)

            if @messages[cid] != nil
              message = @messages[cid]
            else
              transaction.fail!(:NXDomain,@zone) 
              return
            end

            if message.length <= bit
              transaction.fail!(:NXDomain,@zone) 
              return
            end 

            # If the bit is equal to 1 we should return one of the BeEF's IP addresses
            if message[bit] == '1'
              transaction.respond!(@selfip)
              return
            # If the bit is equal to 0 we should return NXDomain message  
            elsif  message[bit] == '0'
              transaction.fail!(:NXDomain,@zone) 
              return
            end
          end
        end  

      private

        # Helper method that formats the given resource class in a human-readable format.
        #
        # @param resource [Resolv::DNS::Resource::IN] resource class
        # @return [String] resource name stripped of any module/class names
        def format_resource(resource)
          /::(\w+)$/.match(resource.name)[1]
        end

      end
    end
  end
end
