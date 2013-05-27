#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module DNS

  # This class handles the routing of RESTful API requests that query BeEF's DNS server
  class DNSRest < BeEF::Core::Router::Router

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
    get '/rules' do
      result = {}
      result[:rules] = BeEF::Extension::DNS::DNS.instance.get_ruleset
      result.to_json
    end

    # Returns a specific rule given its id
    get '/rule/:id' do
      begin
        id = params[:id]

        unless BeEF::Filters.alphanums_only?(id)
          raise StandardError, 'Invalid id passed to endpoint /api/dns/rule/:id'
        end

        result = BeEF::Extension::DNS::DNS.instance.get_rule(id)
        result.to_json
      rescue StandardError => e
        print_error e.message
        halt 400
      end
    end

    # Adds a new DNS rule
    post '/rule' do
      begin
        body = JSON.parse(request.body.read)

        pattern = body['pattern']
        type = eval body['type']
        block = body['block']

        # Validate required JSON keys
        unless [pattern, type, block].include?(nil)
          # Determine whether 'pattern' is a String or Regexp
          begin
            pattern_test = eval pattern
            pattern = pattern_test if pattern_test.class == Regexp
          rescue => e; end

          if type.superclass != Resolv::DNS::Resource
            raise StandardError, 'Invalid resource type given in "type" key'
          end

          unless BeEF::Filters.is_non_empty_string?(block)
            raise StandardError, 'Invalid code block given in "block" key'
          end

          id = ''

          # Bypass #add_rule so that 'block' can be passed as a String
          BeEF::Extension::DNS::DNS.instance.instance_eval do
            id = @server.match(pattern, type, block)
          end

          result = {}
          result['success'] = true
          result['id'] = id
          result.to_json
        end
      rescue StandardError => e
        print_error e.message
        halt 400
      rescue Exception => e
        print_error 'Invalid JSON input passed to endpoint /api/dns/rule'
        halt 400
      end
    end

    # Removes a rule given its id
    delete '/rule/:id' do
      begin
        id = params[:id]

        unless BeEF::Filters.alphanums_only?(id)
          raise StandardError, 'Invalid id passed to endpoint /api/dns/rule/:id'
        end

        BeEF::Extension::DNS::DNS.instance.remove_rule(id)
      rescue StandardError => e
        print_error e.message
        halt 400
      end
    end

  end

end
end
end
