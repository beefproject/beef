#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Network

      # This class handles the routing of RESTful API requests that interact with network services on the zombie's LAN
      class NetworkRest < BeEF::Core::Router::Router

        # Filters out bad requests before performing any routing
        before do
          config = BeEF::Core::Configuration.instance
          @nh = BeEF::Core::Models::NetworkHost
          @ns = BeEF::Core::Models::NetworkService

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # Returns the entire list of network hosts for all zombies
        get '/hosts' do
          begin
            hosts = @nh.all(:unique => true, :order => [:id.asc])
            count = hosts.length

            result = {}
            result[:count] = count
            result[:hosts] = hosts.to_json
            result.to_json
          rescue StandardError => e
            print_error "Internal error while retrieving host list (#{e.message})"
            halt 500
          end
        end

        # Returns the entire list of network services for all zombies
        get '/services' do
          begin
            services = @ns.all(:unique => true, :order => [:id.asc])
            count = services.length

            result = {}
            result[:count] = count
            result[:services] = services.to_json
            result.to_json
          rescue StandardError => e
            print_error "Internal error while retrieving service list (#{e.message})"
            halt 500
          end
        end

        # Returns all hosts given a specific hooked browser id
        get '/hosts/:id' do
          begin
            id = params[:id]

            hosts = @nh.all(:hooked_browser_id => id, :unique => true, :order => [:id.asc])
            count = hosts.length

            result = {}
            result[:count] = count
            result[:hosts] = hosts
            result.to_json
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while retrieving hosts list for hooked browser with id #{id} (#{e.message})"
            halt 500
          end
        end

        # Returns all services given a specific hooked browser id
        get '/services/:id' do
          begin
            id = params[:id]

            services = @ns.all(:hooked_browser_id => id, :unique => true, :order => [:id.asc])
            count = services.length

            result = {}
            result[:count] = count
            result[:services] = services
            result.to_json
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while retrieving service list for hooked browser with id #{id} (#{e.message})"
            halt 500
          end
        end

        # Returns a specific host given its id
        get '/host/:id' do
          begin
            id = params[:id]

            host = @nh.all(:id => id)
            raise InvalidParamError, 'id' if host.nil?
            halt 404 if host.empty?

            host.to_json
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while retrieving host with id #{id} (#{e.message})"
            halt 500
          end
        end

        # Removes a specific host given its id
        delete '/host/:id' do
          begin
            id = params[:id]
            raise InvalidParamError, 'id' if id !~ /\A\d+\z/

            host = @nh.all(:id => id)
            halt 404 if host.nil?

            result = {}
            result['success'] = @nh.delete(id)
            result.to_json
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while removing network host with id #{id} (#{e.message})"
            halt 500
          end
        end

        # Returns a specific service given its id
        get '/service/:id' do
          begin
            id = params[:id]

            service = @ns.all(:id => id)
            raise InvalidParamError, 'id' if service.nil?
            halt 404 if service.empty?

            service.to_json
          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while retrieving service with id #{id} (#{e.message})"
            halt 500
          end
        end

        # Raised when invalid JSON input is passed to an /api/network handler.
        class InvalidJsonError < StandardError

          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/network handler'

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end

        end

        # Raised when an invalid named parameter is passed to an /api/network handler.
        class InvalidParamError < StandardError

          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/network handler'

          def initialize(message = nil)
            str = "Invalid \"%s\" parameter passed to /api/network handler"
            message = sprintf str, message unless message.nil?
            super(message)
          end

        end

      end

    end
  end
end
