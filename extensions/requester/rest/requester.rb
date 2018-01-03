#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
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
          @hb = BeEF::Core::Models::HookedBrowser

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # @TODO: Move methods from the requester controller here

        # Raised when invalid JSON input is passed to an /api/requester handler.
        class InvalidJsonError < StandardError

          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/requester handler'

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end

        end

        # Raised when an invalid named parameter is passed to an /api/requester handler.
        class InvalidParamError < StandardError

          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/requester handler'

          def initialize(message = nil)
            str = "Invalid \"%s\" parameter passed to /api/requester handler"
            message = sprintf str, message unless message.nil?
            super(message)
          end

        end

      end

    end
  end
end
