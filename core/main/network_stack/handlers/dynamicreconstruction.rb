#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module NetworkStack
      module Handlers

        # @note DynamicHandler is used reconstruct segmented traffic from the hooked browser
        class DynamicReconstruction < BeEF::Core::Router::Router

          # @note holds packet queue
          PQ = Array.new()

          # @note obtain dynamic mount points from HttpHookServer
          MOUNTS = BeEF::Core::Server.instance.mounts

          before do
            error 404 unless !params.empty?
            headers 'Pragma' => 'no-cache',
                    'Cache-Control' => 'no-cache',
                    'Expires' => '0'
          end

          # Combines packet information and pushes to PQ (packet queue), then checks packets
          get '/' do
            headers 'Pragma' => 'no-cache',
                    'Cache-Control' => 'no-cache',
                    'Expires' => '0',
                    'Content-Type' => 'text/javascript',
                    'Access-Control-Allow-Origin' => '*',
                    'Access-Control-Allow-Methods' => 'POST, GET'

            PQ << {
                :beefhook => params[:bh],
                :stream_id => Integer(params[:sid]),
                :packet_id => Integer(params[:pid]),
                :packet_count => Integer(params[:pc]),
                :data => params[:d]
            }

            Thread.new {
              check_packets()
            }
          end

          # Check packets goes through the PQ array and attempts to reconstruct the stream from multiple packets
          def check_packets()
            checked = Array.new()
            PQ.each do |packet|
              if (checked.include?(packet[:beefhook]+':'+String(packet[:stream_id])))
                next
              end
              checked << packet[:beefhook]+':'+String(packet[:stream_id])
              pc = 0
              PQ.each do |p|
                if (packet[:beefhook] == p[:beefhook] and packet[:stream_id] == p[:stream_id])
                  pc += 1
                end
              end
              if (packet[:packet_count] == pc)
                packets = expunge(packet[:beefhook], packet[:stream_id])
                data = ''
                packets.each_with_index do |sp, i|
                  if (packet[:beefhook] == sp[:beefhook] and packet[:stream_id] == sp[:stream_id])
                    data += sp[:data]
                  end
                end
                b64 = Base64.decode64(data)
                begin
                  res = JSON.parse(b64).first
                  res['beefhook'] = packet[:beefhook]
                  res['request'] = request
                  res['beefsession'] = request[BeEF::Core::Configuration.instance.get('beef.http.hook_session_name')]
                  execute(res)
                rescue JSON::ParserError => e
                  print_debug 'Network stack could not decode packet stream.'
                  print_debug 'Dumping Stream Data [base64]: '+data
                  print_debug 'Dumping Stream Data: '+b64
                end
              end
            end
          end

          # Delete packets that have been reconstructed, return deleted packets
          # @param [String] beefhook Beefhook of hooked browser
          # @param [Integer] stream_id The stream ID
          def expunge(beefhook, stream_id)
            packets = PQ.select { |p| p[:beefhook] == beefhook and p[:stream_id] == stream_id }
            PQ.delete_if { |p| p[:beefhook] == beefhook and p[:stream_id] == stream_id }
            packets.sort_by { |p| p[:packet_id] }
          end

          # Execute is called once a stream has been rebuilt. it searches the mounts and passes the data to the correct handler
          # @param [Hash] data Hash of data that has been rebuilt by the dynamic reconstruction
          def execute(data)
            handler = get_param(data, 'handler')
            if (MOUNTS.has_key?(handler))
              if (MOUNTS[handler].class == Array and MOUNTS[handler].length == 2)
                MOUNTS[handler][0].new(data, MOUNTS[handler][1])
              else
                MOUNTS[handler].new(data)
              end
            end
          end

          # Assist function for getting parameter from hash
          # @param [Hash] query Hash to pull key from
          # @param [String] key The key association to return from `query`
          # @return Value associated with `key`
          def get_param(query, key)
            return nil if query[key].nil?
            query[key]
          end
        end
      end
    end
  end
end
