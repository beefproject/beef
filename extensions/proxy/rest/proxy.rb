#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Proxy

      # This class handles the routing of RESTful API requests for the proxy
      class ProxyRest < BeEF::Core::Router::Router

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

        # Use a specified hooked browser as proxy
        post '/setTargetZombie' do
          begin
            body = JSON.parse(request.body.read)
            hb_id = body['hb_id']

            result = {}
            result['success'] = false
            return result.to_json if hb_id.nil?

            hooked_browser = @hb.first(:session => hb_id)
            previous_proxy_hb = @hb.first(:is_proxy => true)

            # if another HB is currently set as tunneling proxy, unset it
            unless previous_proxy_hb.nil?
              previous_proxy_hb.update(:is_proxy => false)
              print_debug("Unsetting previously HB [#{previous_proxy_hb.ip}] used as Tunneling Proxy")
            end

            # set the HB requested in /setTargetProxy as Tunneling Proxy
            unless hooked_browser.nil?
              hooked_browser.update(:is_proxy => true)
              print_info("Using Hooked Browser with ip [#{hooked_browser.ip}] as Tunneling Proxy")
              result['success'] = true
            end

            result.to_json

          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error setting browser as proxy (#{e.message})"
            halt 500
          end

        end

        # Raised when invalid JSON input is passed to an /api/proxy handler.
        class InvalidJsonError < StandardError

          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/proxy handler'

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end

        end

        # Raised when an invalid named parameter is passed to an /api/proxy handler.
        class InvalidParamError < StandardError

          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/proxy handler'

          def initialize(message = nil)
            str = "Invalid \"%s\" parameter passed to /api/proxy handler"
            message = sprintf str, message unless message.nil?
            super(message)
          end

        end

      end

    end
  end
end
