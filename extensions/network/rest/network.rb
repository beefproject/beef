#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
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
          @hb = BeEF::Core::Models::HookedBrowser

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
          hosts = @nh.all.distinct.order(:id)
          count = hosts.length

          result = {}
          result[:count] = count
          result[:hosts] = []
          hosts.each do |host|
            result[:hosts] << host.to_h
          end

          result.to_json
        rescue StandardError => e
          print_error "Internal error while retrieving host list (#{e.message})"
          halt 500
        end

        # Returns the entire list of network services for all zombies
        get '/services' do
          services = @ns.all.distinct.order(:id)
          count = services.length

          result = {}
          result[:count] = count
          result[:services] = []
          services.each do |service|
            result[:services] << service.to_h
          end

          result.to_json
        rescue StandardError => e
          print_error "Internal error while retrieving service list (#{e.message})"
          halt 500
        end

        # Returns all hosts given a specific hooked browser id
        get '/hosts/:id' do
          id = params[:id]

          hooked_browser = @hb.where(session: id).distinct
          hosts = @nh.where(hooked_browser: hooked_browser).distinct.order(:hooked_browser)
          count = hosts.length

          result = {}
          result[:count] = count
          result[:hosts] = []
          hosts.each do |host|
            result[:hosts] << host.to_h
          end

          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving hosts list for hooked browser with id #{id} (#{e.message})"
          halt 500
        end

        # Returns all services given a specific hooked browser id
        get '/services/:id' do
          id = params[:id]

          services = @ns.where(hooked_browser_id: id).distinct.order(:id)
          count = services.length

          result = {}
          result[:count] = count
          result[:services] = []
          services.each do |service|
            result[:services] << service.to_h
          end

          result.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving service list for hooked browser with id #{id} (#{e.message})"
          halt 500
        end

        # Returns a specific host given its id
        get '/host/:id' do
          id = params[:id]

          host = @nh.find(id)
          raise InvalidParamError, 'id' if host.nil?

          halt 404 if host.nil?

          host.to_h.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving host with id #{id} (#{e.message})"
          halt 500
        end

        # Deletes a specific host given its id
        delete '/host/:id' do
          id = params[:id]
          raise InvalidParamError, 'id' unless BeEF::Filters.nums_only?(id)

          host = @nh.find(id)
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

        # Returns a specific service given its id
        get '/service/:id' do
          id = params[:id]

          service = @ns.find(id)
          raise InvalidParamError, 'id' if service.nil?

          halt 404 if service.empty?

          service.to_h.to_json
        rescue InvalidParamError => e
          print_error e.message
          halt 400
        rescue StandardError => e
          print_error "Internal error while retrieving service with id #{id} (#{e.message})"
          halt 500
        end

        # Raised when invalid JSON input is passed to an /api/network handler.
        class InvalidJsonError < StandardError
          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/network handler'.freeze

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end
        end

        # Raised when an invalid named parameter is passed to an /api/network handler.
        class InvalidParamError < StandardError
          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/network handler'.freeze

          def initialize(message = nil)
            message = "Invalid \"#{message}\" parameter passed to /api/network handler" unless message.nil?
            super(message)
          end
        end
      end
    end
  end
end
