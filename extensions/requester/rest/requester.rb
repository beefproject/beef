#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Requester
      # This class handles the routing of RESTful API requests for the requester
      class RequesterRest < BeEF::Core::Router::Router
        # Filters out bad requests before performing any routing
        before do
          config = BeEF::Core::Configuration.instance

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          H = BeEF::Core::Models::Http
          HB = BeEF::Core::Models::HookedBrowser

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Returns a request by ID
        get '/request/:id' do
          id = params[:id]
          raise InvalidParamError, 'id' unless BeEF::Filters.nums_only?(id)

          requests = H.find(id)
          halt 404 if requests.nil?

          result = {}
          result[:count] = requests.length
          result[:requests] = []
          requests.each do |request|
            result[:requests] << request2hash(request)
          end

          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving request with id #{id} (#{e.message})"
          halt 500
        end

        # Returns all requestes given a specific hooked browser id
        get '/requests/:id' do
          id = params[:id]
          raise InvalidParamError, 'id' unless BeEF::Filters.is_valid_hook_session_id?(id)

          requests = H.where(hooked_browser_id: id)
          halt 404 if requests.nil?

          result = {}
          result[:count] = requests.length
          result[:requests] = []
          requests.each do |request|
            result[:requests] << request2hash(request)
          end

          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving request list for hooked browser with id #{id} (#{e.message})"
          halt 500
        end

        # Return a response by ID
        get '/response/:id' do
          # super debugging

          error = {}

          error[:code] = 0

          id = params[:id]
          raise InvalidParamError, 'id' unless BeEF::Filters.nums_only?(id)

          error[:code] = 1

          responses = H.find(id) || nil
          error[:code] = 2
          halt 404 if responses.nil?
          error[:code] = 3
          result = {}
          result[:success] = 'true'
          error[:code] = 4

          result[:result] = response2hash(responses)
          error[:code] = 5

          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving response with id #{id} (#{e.message})"

          error[:id] = id
          error[:message] = e.message
          error.to_json
          # halt 500
        end

        # Deletes a specific response given its id
        delete '/response/:id' do
          id = params[:id]
          raise InvalidParamError, 'id' unless BeEF::Filters.nums_only?(id)

          responses = H.find(id) || nil
          halt 404 if responses.nil?

          result = {}
          result['success'] = H.delete(id)
          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while removing response with id #{id} (#{e.message})"
          halt 500
        end

        # Send a new HTTP request to the hooked browser
        post '/send/:id' do
          id = params[:id]
          proto = params[:proto].to_s || 'http'
          raw_request = params['raw_request'].to_s

          zombie = HB.where(session: id).first || nil
          halt 404 if zombie.nil?

          # @TODO: move most of this to the model

          raise InvalidParamError, 'raw_request' if raw_request == ''

          raise InvalidParamError, 'raw_request: Invalid request URL scheme' if proto !~ /\Ahttps?\z/

          req_parts = raw_request.split(/ |\n/)

          verb = req_parts[0]
          raise InvalidParamError, 'raw_request: Only HEAD, GET, POST, OPTIONS, PUT or DELETE requests are supported' unless BeEF::Filters.is_valid_verb?(verb)

          uri = req_parts[1]
          raise InvalidParamError, 'raw_request: Invalid URI' unless BeEF::Filters.is_valid_url?(uri)

          version = req_parts[2]
          raise InvalidParamError, 'raw_request: Invalid HTTP version' unless BeEF::Filters.is_valid_http_version?(version)

          host_str = req_parts[3]
          raise InvalidParamError, 'raw_request: Invalid HTTP version' unless BeEF::Filters.is_valid_host_str?(host_str)

          # Validate target hsot
          host = req_parts[4]
          host_parts = host.split(/:/)
          host_name = host_parts[0]
          host_port = host_parts[1] || nil

          raise InvalidParamError, 'raw_request: Invalid HTTP HostName' unless BeEF::Filters.is_valid_hostname?(host_name)

          host_port = host_parts[1] || nil
          if host_port.nil? || !BeEF::Filters.nums_only?(host_port)
            host_port = proto.eql?('https') ? 443 : 80
          end

          # Save the new HTTP request
          http = H.new(
            hooked_browser_id: zombie.session,
            request: raw_request,
            method: verb,
            proto: proto,
            domain: host_name,
            port: host_port,
            path: uri,
            request_date: Time.now,
            allow_cross_domain: 'true'
          )

          print_debug "added new http request for #{zombie.session}"
          print_debug http.to_json

          if verb.eql?('POST') || verb.eql?('PUT')
            req_parts.each_with_index do |value, index|
              http.content_length = req_parts[index + 1] if value.match(/^Content-Length/i)
            end
          end

          http.save

          result = request2hash(http)
          print_debug "[Requester] Sending HTTP request through zombie [ip: #{zombie.ip}] : #{result}"

          # result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while removing network host with id #{id} (#{e.message})"
          halt 500
        end

        # Convert a request object to Hash
        def request2hash(http)
          {
            id: http.id,
            proto: http.proto,
            domain: http.domain,
            port: http.port,
            path: http.path,
            has_ran: http.has_ran,
            method: http.method,
            request_date: http.request_date,
            response_date: http.response_date,
            response_status_code: http.response_status_code,
            response_status_text: http.response_status_text,
            response_port_status: http.response_port_status
          }
        end

        # Convert a response object to Hash
        def response2hash(http)
          response_data = ''

          unless http.response_data.nil?
            if (http.response_data.length > (1024 * 100)) # more than 100K
              response_data = http.response_data[0..(1024 * 100)]
              response_data += "\n<---------- Response Data Truncated---------->"
            else
              response_data = http.response_data
            end
          end

          response_headers = ''
          response_headers = http.response_headers unless http.response_headers.nil?

          {
            id: http.id,
            request: http.request.force_encoding('UTF-8'),
            response: response_data.force_encoding('UTF-8'),
            response_headers: response_headers.force_encoding('UTF-8'),
            proto: http.proto.force_encoding('UTF-8'),
            domain: http.domain.force_encoding('UTF-8'),
            port: http.port.force_encoding('UTF-8'),
            path: http.path.force_encoding('UTF-8'),
            date: http.request_date,
            has_ran: http.has_ran.force_encoding('UTF-8')
          }
        end

        # Raised when invalid JSON input is passed to an /api/requester handler.
        class InvalidJsonError < StandardError
          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/requester handler'.freeze

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end
        end

        # Raised when an invalid named parameter is passed to an /api/requester handler.
        class InvalidParamError < StandardError
          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/requester handler'.freeze

          def initialize(message = nil)
            str = 'Invalid "%s" parameter passed to /api/requester handler'
            message = format str, message unless message.nil?
            super(message)
          end
        end
      end
    end
  end
end
