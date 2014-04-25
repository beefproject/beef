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
          @database = BeEF::Core::Models::Dns::Rule
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

        # Entry point for processing incoming DNS requests. Attempts to find a matching rule and
        # sends back its associated response.
        #
        # @param name [String] name of the resource record being looked up
        # @param resource [Resolv::DNS::Resource::IN] query type (e.g. A, CNAME, NS, etc.)
        # @param transaction [RubyDNS::Transaction] internal RubyDNS class detailing DNS question/answer
        def process(name, resource, transaction)
          @lock.synchronize do
	        print_debug "Received DNS request (name: #{name} type: #{format_resource(resource)})"

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

              # When no match is found, query upstream servers (if enabled)
              if @otherwise
                print_debug "No match found, querying upstream servers"
                @otherwise.call(transaction)
              else
                print_debug "Failed to handle DNS request for #{name}"
              end
            end
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
