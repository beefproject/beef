#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Dns

  # This class handles the routing of RESTful API requests that query BeEF's DNS server
  class DnsRest < BeEF::Core::Router::Router

    # Filters out bad requests before performing any routing
    before do
      config = BeEF::Core::Configuration.instance

      # Require a valid API token from a valid IP address
      error 401 unless params[:token] == config.get('beef.api_token')
      halt  401 unless BeEF::Core::Rest.permitted_source?(request.ip)

      headers 'Content-Type' => 'application/json; charset=UTF-8',
              'Pragma' => 'no-cache',
              'Cache-Control' => 'no-cache',
              'Expires' => '0'
    end

    # Returns the entire current DNS ruleset
    get '/ruleset' do
      begin
        ruleset = BeEF::Extension::Dns::Server.instance.get_ruleset
        count = ruleset.length

        result = {}
        result[:count] = count
        result[:ruleset] = ruleset
        result.to_json
      rescue StandardError => e
        print_error "Internal error while retrieving DNS ruleset (#{e.message})"
        halt 500
      end
    end

    # Returns a specific rule given its id
    get '/rule/:id' do
      begin
        id = params[:id]

        unless BeEF::Filters.alphanums_only?(id)
          raise InvalidParamError, 'Invalid "id" parameter passed to endpoint /api/dns/rule/:id'
        end

        result = BeEF::Extension::Dns::Server.instance.get_rule(id)
        result.to_json
      rescue InvalidParamError => e
        print_error e.message
        halt 400
      rescue StandardError => e
        print_error "Internal error while retrieving DNS rule with id #{id} (#{e.message})"
        halt 500
      end
    end

    # Adds a new DNS rule
    post '/rule' do
      begin
        body = JSON.parse(request.body.read)

        pattern = body['pattern']
        type = body['type']
        response = body['response']

        # Validate required JSON keys
        unless [pattern, type, response].include?(nil)
          # Determine whether 'pattern' is a String or Regexp
          begin
            pattern_test = eval pattern
            pattern = pattern_test if pattern_test.class == Regexp
          rescue => e; end

          if response.class == Array
              if response.length == 0
                raise InvalidJsonError, 'Empty "reponse" key passed to endpoint /api/dns/rule'
              end
          else
            raise InvalidJsonError, 'Non-array "reponse" key passed to endpoint /api/dns/rule'
          end

          unless BeEF::Filters.is_non_empty_string?(pattern)
            raise InvalidJsonError, 'Empty "pattern" key passed to endpoint /api/dns/rule'
          end

          unless BeEF::Filters.is_non_empty_string?(type)
            raise InvalidJsonError, 'Empty "type" key passed to endpoint /api/dns/rule'
          end

          id = ''

          type_obj  = eval "Resolv::DNS::Resource::IN::#{type}"
          block_src = format_response(type, response)

          # Bypass #add_rule so that 'block_src' can be passed as a String
          BeEF::Extension::Dns::Server.instance.instance_eval do
            id = @server.match(pattern, type_obj, block_src)
          end

          result = {}
          result['success'] = true
          result['id'] = id
          result.to_json
        end
      rescue InvalidJsonError => e
        print_error e.message
        halt 400
      rescue StandardError => e
        print_error "Internal error while adding DNS rule (#{e.message})"
        halt 500
      end
    end

    # Removes a rule given its id
    delete '/rule/:id' do
      begin
        id = params[:id]

        unless BeEF::Filters.alphanums_only?(id)
          raise InvalidParamError, 'Invalid "id" parameter passed to endpoint /api/dns/rule/:id'
        end

        BeEF::Extension::Dns::Server.instance.remove_rule(id)
      rescue InvalidParamError => e
        print_error e.message
        halt 400
      rescue StandardError => e
        print_error "Internal error while removing DNS rule with id #{id} (#{e.message})"
        halt 500
      end
    end

    private

    # Generates a formatted string representation of the callback to invoke as a response.
    #
    # @param [String] type resource record type (e.g. A, CNAME, NS, etc.)
    # @param [Array] rdata record data to include in response
    #
    # @return [String] string representation of response callback
    def format_response(type, rdata)
      src = 'proc { |t| t.respond!(%s) }'

      args = case type
             when 'A'
               data = { :address => rdata[0] }
               sprintf "'%<address>s'", data
             when 'AAAA'
               data = { :address => rdata[0] }
               sprintf "'%<address>s'", data
             when 'CNAME'
               data = { :cname => rdata[0] }
               sprintf "Resolv::DNS::Name.create('%<cname>s')", data
             when 'HINFO'
               data = { :cpu => rdata[0], :os => rdata[1] }
               sprintf "'%<cpu>s', '%<os>s'", data
             when 'MINFO'
               data = { :rmailbx => rdata[0], :emailbx => rdata[1] }

               sprintf "Resolv::DNS::Name.create('%<rmailbx>s'), " +
                       "Resolv::DNS::Name.create('%<emailbx>s')",
                       data
             when 'MX'
               data = { :preference => rdata[0], :exchange => rdata[1] }
               sprintf "'%<preference>d', Resolv::DNS::Name.create('%<exchange>s')", data
             when 'NS'
               data = { :nsdname => rdata[0] }
               sprintf "Resolv::DNS::Name.create('%<nsdname>s')", data
             when 'PTR'
               data = { :ptrdname => rdata[0] }
               sprintf "Resolv::DNS::Name.create('%<ptrdname>s')", data
             when 'SOA'
               data = {
                 :mname   => rdata[0],
                 :rname   => rdata[1],
                 :serial  => rdata[2],
                 :refresh => rdata[3],
                 :retry   => rdata[4],
                 :expire  => rdata[5],
                 :minimum => rdata[6]
               }

               sprintf "Resolv::DNS::Name.create('%<mname>s'), " +
                       "Resolv::DNS::Name.create('%<rname>s'), " +
                       '%<serial>d, ' +
                       '%<refresh>d, ' +
                       '%<retry>d, ' +
                       '%<expire>d, ' +
                       '%<minimum>d',
                       data
             when 'TXT'
               data = { :txtdata => rdata[0] }
               sprintf "'%<txtdata>s'", data
             when 'WKS'
               data = {
                 :address  => rdata[0],
                 :protocol => rdata[1],
                 :bitmap   => rdata[2]
               }

               sprintf "'%<address>s', %<protocol>d, %<bitmap>d", data
             else
               raise InvalidJsonError, 'Unknown "type" key passed to endpoint /api/dns/rule'
             end

      sprintf(src, args)
    end

    # Raised when invalid JSON input is passed to an /api/dns handler.
    class InvalidJsonError < StandardError

      DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/dns handler'

      def initialize(message = nil)
        super(message || DEFAULT_MESSAGE)
      end

    end

    # Raised when an invalid named parameter is passed to an /api/dns handler.
    class InvalidParamError < StandardError

      DEFAULT_MESSAGE = 'Invalid parameter passed to /api/dns handler'

      def initialize(message = nil)
        super(message || DEFAULT_MESSAGE)
      end

    end

  end

end
end
end
