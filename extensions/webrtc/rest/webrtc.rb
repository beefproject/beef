#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module WebRTC

      # This class handles the routing of RESTful API requests that manage the WebRTC Extension
      class WebRTCRest < BeEF::Core::Router::Router

        # Filters out bad requests before performing any routing
        before do
          config = BeEF::Core::Configuration.instance

          # Require a valid API token from a valid IP address
          halt 401 unless params[:token] == config.get('beef.api_token')
          halt 403 unless BeEF::Core::Rest.permitted_source?(request.ip)

          headers 'Content-Type' => 'application/json; charset=UTF-8',
                  'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        #
        # @note Initiate two browsers to establish a WebRTC PeerConnection
        # Return success = true if the message has been queued - as this is asynchronous, you will have to monitor BeEFs event log 
        #   for success messages. For instance: Event: Browser:1 received message from Browser:2: ICE Status: connected
        #
        # Input must be specified in JSON format
        #
        # +++ Example: +++
        #POST /api/webrtc/go?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #Content-Type: application/json; charset=UTF-8
        #
        #{"from":1, "to":2}
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"success":"true"}
        #
        # +++ Example with verbosity on the client-side +++
        #POST /api/webrtc/go?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #Content-Type: application/json; charset=UTF-8
        #
        #{"from":1, "to":2, "verbose": true}
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"success":"true"}
        #
        # +++ Example with curl +++
        # curl -H "Content-type: application/json; charset=UTF-8" -v
        #  -X POST -d '{"from":1,"to":2,"verbose":true}'
        #  http://127.0.0.1:3000/api/webrtc/go\?token\=df67654b03d030d97018f85f0284247d7f49c348
        post '/go' do
          begin
            body = JSON.parse(request.body.read)

            fromhb = body['from']
            tohb = body['to']
            verbose = body['verbose']

            result = {}

            unless [fromhb,tohb].include?(nil)
              if verbose == nil 
                BeEF::Core::Models::Rtcmanage.initiate(fromhb.to_i, tohb.to_i)
                result['success'] = true
              else
                if verbose.to_s =~ (/^(true|t|yes|y|1)$/i)
                  BeEF::Core::Models::Rtcmanage.initiate(fromhb.to_i, tohb.to_i,true)
                  result['success'] = true
                else
                  BeEF::Core::Models::Rtcmanage.initiate(fromhb.to_i, tohb.to_i)
                  result['success'] = true
                end
              end
            else
              result['success'] = false
            end

            result.to_json

          rescue StandardError => e
            print_error "Internal error while initiating RTCPeerConnections .. (#{e.message})"
            halt 500
          end
        end

        #
        # @note Get the RTCstatus of a particular browser (and its peers)
        # Return success = true if the message has been queued - as this is asynchronous, you will have to monitor BeEFs event log 
        #   for success messages. For instance: Event: Browser:1 received message from Browser:2: Status checking - allgood: true
        #
        # +++ Example: +++
        #GET /api/webrtc/status/1?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"success":"true"}
        #
        # +++ Example with curl +++
        # curl -H "Content-type: application/json; charset=UTF-8" -v
        #  -X GET http://127.0.0.1:3000/api/webrtc/status/1\?token\=df67654b03d030d97018f85f0284247d7f49c348
        get '/status/:id' do
          begin
            id = params[:id]

            BeEF::Core::Models::Rtcmanage.status(id.to_i)
            result = {}
            result['success'] = true
            result.to_json

          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while queuing status message for #{id} (#{e.message})"
            halt 500
          end
        end

        #
        # @note Instruct a browser to send an RTC DataChannel message to one of its peers
        # Return success = true if the message has been queued - as this is asynchronous, you will have to monitor BeEFs event log 
        #   for success messages, IF ANY. 
        #
        # Input must be specified in JSON format
        #
        # +++ Example: +++
        #POST /api/webrtc/msg?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #Content-Type: application/json; charset=UTF-8
        #
        #{"from":1, "to":2, "message":"Just a plain message"}
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"success":"true"}
        #
        # +++ Example with curl +++
        # curl -H "Content-type: application/json; charset=UTF-8" -v
        #  -X POST -d '{"from":1,"to":2,"message":"Just a plain message"}'
        #  http://127.0.0.1:3000/api/webrtc/go\?token\=df67654b03d030d97018f85f0284247d7f49c348
        #
        # Available client-side "message" options and handling:
        #  !gostealth - will put the <to> browser into a stealth mode
        #  !endstealth - will put the <to> browser into normal mode, and it will start talking to BeEF again
        #  %<javascript> - will execute JavaScript on <to> sending the results back to <from> - who will relay back to BeEF
        #  <text> - will simply send a datachannel message from <from> to <to>.
        #           If the <to> is stealthed, it'll bounce the message back.
        #           If the <to> is NOT stealthed, it'll send the message back to BeEF via the /rtcmessage handler
        post '/msg' do
          begin

            body = JSON.parse(request.body.read)

            fromhb = body['from']
            tohb = body['to']
            message = body['message']

            result = {}

            unless [fromhb,tohb,message].include?(nil)
              BeEF::Core::Models::Rtcmanage.sendmsg(fromhb.to_i, tohb.to_i, message)
              result['success'] = true
            else
              result['success'] = false
            end

            result.to_json

          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while queuing message for #{id} (#{e.message})"
            halt 500
          end

        end

        # Raised when invalid JSON input is passed to an /api/webrtc handler.
        class InvalidJsonError < StandardError

          DEFAULT_MESSAGE = 'Invalid JSON input passed to /api/webrtc handler'

          def initialize(message = nil)
            super(message || DEFAULT_MESSAGE)
          end

        end

        # Raised when an invalid named parameter is passed to an /api/webrtc handler.
        class InvalidParamError < StandardError

          DEFAULT_MESSAGE = 'Invalid parameter passed to /api/webrtc handler'

          def initialize(message = nil)
            str = "Invalid \"%s\" parameter passed to /api/webrtc handler"
            message = sprintf str, message unless message.nil?
            super(message)
          end

        end

      end

    end
  end
end
