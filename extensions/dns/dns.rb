#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
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
          @database = BeEF::Core::Models::Dns::Rule
          @data_chunks = Hash.new
        end

        # Adds a new DNS rule. If the rule already exists, its current ID is returned.
        #
        # @example Adds an A record for browserhacker.com with the IP address 1.2.3.4
        #
        #   dns = BeEF::Extension::Dns::Server.instance
        #
        #   id = dns.add_rule(
        #     :pattern  => 'browserhacker.com',
        #     :resource => Resolv::DNS::Resource::IN::A,
        #     :response => '1.2.3.4'
        #   )
        #
        # @param rule [Hash] hash representation of rule
        # @option rule [String, Regexp] :pattern match criteria
        # @option rule [Resolv::DNS::Resource::IN] :resource resource record type
        # @option rule [String, Array] :response server response
        #
        # @return [String] unique 8-digit hex identifier
        def add_rule(rule = {})
          @lock.synchronize do
            # Temporarily disable warnings regarding IGNORECASE flag
            verbose = $VERBOSE
            $VERBOSE = nil
            pattern = Regexp.new(rule[:pattern], Regexp::IGNORECASE)
            $VERBOSE = verbose

            @database.first_or_create(
              { :resource => rule[:resource], :pattern => pattern.source },
              { :response => rule[:response] }
            ).id
          end
        end

        # Retrieves a specific rule given its identifier.
        #
        # @param id [String] unique identifier for rule
        #
        # @return [Hash] hash representation of rule (empty hash if rule wasn't found)
        def get_rule(id)
          @lock.synchronize do
            if is_valid_id?(id)
              rule = @database.get(id)
              rule.nil? ? {} : to_hash(rule)
            end
          end
        end

        # Removes the given DNS rule.
        #
        # @param id [String] rule identifier
        #
        # @return [Boolean] true if rule was removed, otherwise false
        def remove_rule!(id)
          @lock.synchronize do
            if is_valid_id?(id)
              rule = @database.get(id)
              rule.nil? ? false : rule.destroy
            end
          end
        end

        # Returns an AoH representing the entire current DNS ruleset.
        #
        # Each element is a hash with the following keys:
        #
        # * <code>:id</code>
        # * <code>:pattern</code>
        # * <code>:resource</code>
        # * <code>:response</code>
        #
        # @return [Array<Hash>] DNS ruleset (empty array if no rules are currently defined)
        def get_ruleset
          @lock.synchronize { @database.collect { |rule| to_hash(rule) } }
        end

        # Removes the entire DNS ruleset.
        #
        # @return [Boolean] true if ruleset was destroyed, otherwise false
        def remove_ruleset!
          @lock.synchronize { @database.destroy }
        end

        # Starts the DNS server.
        #
        # @param options [Hash] server configuration options
        # @option options [Array<Array>] :upstream upstream DNS servers (if ommitted, unresolvable
        #   requests return NXDOMAIN)
        # @option options [Array<Array>] :listen local interfaces to listen on
        def run(options = {})
          @lock.synchronize do
            Thread.new do
              EventMachine.next_tick do
                upstream = options[:upstream] || nil
                listen = options[:listen] || nil

                if upstream
                  resolver = RubyDNS::Resolver.new(upstream)
                  @otherwise = Proc.new { |t| t.passthrough!(resolver) }
                end

                begin
                  super(:listen => listen)
                rescue RuntimeError => e
                  if e.message =~ /no datagram socket/ || e.message =~ /no acceptor/ # the port is in use
                    print_error "[DNS] Another process is already listening on port #{options[:listen]}"
                    print_error "Exiting..."
                    exit 127
                  else
                    raise
                  end
                end

              end
            end
          end
        end

        # Entry point for processing incoming DNS requests. Attempts to find a matching rule and
        # sends back its associated response.
        #
        # @param name [String] name of the resource record being looked up
        # @param resource [Resolv::DNS::Resource::IN] query type (e.g. A, CNAME, NS, etc.)
        # @param transaction [RubyDNS::Transaction] internal RubyDNS class detailing DNS question/answer
        def process(name, resource, transaction)
          @lock.synchronize do
	        print_debug "Received DNS request (name: #{name} type: #{format_resource(resource)})"

            # no need to parse AAAA resources when data is extruded from client. Also we check if the FQDN starts with the 0xb3 string.
            # this 0xb3 is convenient to clearly separate DNS requests used to extrude data from normal DNS requests than should be resolved by the DNS server.
            if format_resource(resource) == 'A' and name.match(/^0xb3/)
              reconstruct(name.split('0xb3').last)
              catch (:done) do
                transaction.fail!(:NXDomain)
              end
              return
            end

            catch (:done) do
              # Find rules matching the requested resource class
              resources = @database.all(:resource => resource)
              throw :done if resources.length == 0

              # Narrow down search by finding a matching pattern
              resources.each do |rule|
                pattern = Regexp.new(rule.pattern)

                if name =~ pattern
                  print_debug "Found matching DNS rule (id: #{rule.id} response: #{rule.response})"
                  Proc.new { |t| eval(rule.callback) }.call(transaction)
                  throw :done
                end
              end

              if @otherwise
                print_debug "No match found, querying upstream servers"
                @otherwise.call(transaction)
              else
                print_debug "No match found, sending NXDOMAIN response"
                transaction.fail!(:NXDomain)
              end
            end
          end
        end

        private
        # Collects and reconstructs data extruded by the client and found in subdomain, with structure like:
        #0.1.5.4c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e7.browserhacker.com
        #[...]
        #0.5.5.7565207175616d206469676e697373696d2065752e.browserhacker.com
        def reconstruct(data)
           split_data = data.split('.')
           pack_id = split_data[0]
           seq_num = split_data[1]
           seq_tot = split_data[2]
           data_chunk = split_data[3] # this might change if we store more than 63 bytes in a chunk (63 is the limitation from RFC)

           if pack_id.match(/^(\d)+$/) and seq_num.match(/^(\d)+$/) and seq_tot.match(/^(\d)+$/)
             print_debug "[DNS] Received chunk (#{seq_num} / #{seq_tot}) of packet (#{pack_id}): #{data_chunk}"

             if @data_chunks[pack_id] == nil
                # no previous chunks received, create new Array to store chunks
                @data_chunks[pack_id] = Array.new(seq_tot.to_i)
                @data_chunks[pack_id][seq_num.to_i - 1] = data_chunk
             else
               # previous chunks received, update Array
               @data_chunks[pack_id][seq_num.to_i - 1] = data_chunk
               if @data_chunks[pack_id].all? and @data_chunks[pack_id] != 'DONE'
                 # means that no position in the array is false/nil, so we received all the packet chunks
                 packet_data = @data_chunks[pack_id].join('')
                 decoded_packet_data = packet_data.scan(/../).map{ |n| n.to_i(16)}.pack('U*')
                 print_debug "[DNS] Packet data fully received: #{packet_data}. \n Converted from HEX: #{decoded_packet_data}"

                 # we might get more DNS requests for the same chunks sometimes, once every chunk of a packet is received, mark it
                 @data_chunks[pack_id] = 'DONE'
               end
             end
           else
             print_debug "[DNS] Data (#{data}) is not a valid chunk."
           end
        end

      private
        # Helper method that converts a DNS rule to a hash.
        #
        # @param rule [BeEF::Core::Models::Dns::Rule] rule to be converted
        #
        # @return [Hash] hash representation of DNS rule
        def to_hash(rule)
          hash = {}
          hash[:id] = rule.id
          hash[:pattern] = rule.pattern
          hash[:resource] = format_resource(rule.resource)
          hash[:response] = rule.response

          hash
        end

        # Verifies that the given ID is valid.
        #
        # @param id [String] identifier to validate
        #
        # @return [Boolean] true if ID is valid, otherwise false
        def is_valid_id?(id)
          BeEF::Filters.hexs_only?(id) &&
            !BeEF::Filters.has_null?(id) &&
            !BeEF::Filters.has_non_printable_char?(id) &&
            id.length == 8
        end

        # Helper method that formats the given resource class in a human-readable format.
        #
        # @param resource [Resolv::DNS::Resource::IN] resource class
        #
        # @return [String] resource name stripped of any module/class names
        def format_resource(resource)
          /::(\w+)$/.match(resource.name)[1]
        end

      end

    end
  end
end
