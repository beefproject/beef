#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
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
          @dns ||= BeEF::Extension::Dns::Server.instance
          config = BeEF::Core::Configuration.instance

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Returns the entire current DNS ruleset
        get '/ruleset' do
          begin
            ruleset = @dns.get_ruleset
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

            rule = @dns.get_rule(id)
            raise InvalidParamError, 'id' if rule.nil?
            halt 404 if rule.empty?

            rule.to_json
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
            resource = body['resource']
            response = body['response']

            valid_resources = ["A", "AAAA", "CNAME", "HINFO", "MINFO", "MX", "NS", "PTR", "SOA", "TXT", "WKS"]

            # Validate required JSON keys
            unless [pattern, resource, response].include?(nil)
              if response.is_a?(Array)
                raise InvalidJsonError, 'Empty "response" key passed to endpoint /api/dns/rule' if response.empty?
              else
                raise InvalidJsonError, 'Non-array "response" key passed to endpoint /api/dns/rule'
              end

              raise InvalidJsonError, 'Wrong "resource" key passed to endpoint /api/dns/rule' unless valid_resources.include?(resource)

              id = @dns.add_rule(
                :pattern => pattern,
                :resource => eval("Resolv::DNS::Resource::IN::#{resource}"),
                :response => response
              )

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

            removed = @dns.remove_rule!(id)
            raise InvalidParamError, 'id' if removed.nil?

            result = {}
            result['success'] = removed
            result.to_json
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while removing DNS rule with id #{id} (#{e.message})"
            halt 500
          end
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
            str = "Invalid \"%s\" parameter passed to /api/dns handler"
            message = sprintf str, message unless message.nil?
            super(message)
          end

        end

      end

    end
  end
end
