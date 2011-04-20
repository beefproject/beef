module BeEF
module Core
module NetworkStack
module Handlers
  
  #DynamicHanlder is used reconstruct segmented traffic from the zombies

  class DynamicReconstruction < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard

    #holds packet queue
    PQ = Array.new() 
   
    #obtain dynamic mount points from HttpHookServer
    MOUNTS = BeEF::Core::Server.instance.mounts

    #Combines packet information and pushes to PQ, then checks packets
    def do_POST(request, response)
        @request = request
        response.body = ''
        PQ << {
            :beefhook =>  get_param(@request.query, 'bh'),
            :stream_id => Integer(get_param(@request.query, 'sid')),
            :packet_id => Integer(get_param(@request.query, 'pid')),
            :packet_count => Integer(get_param(@request.query, 'pc')),
            :data => get_param(@request.query, 'd')
        }
        check_packets()
    end
    
    alias do_GET do_POST

    #check packets goes through the PQ array and attempts to reconstruct the stream from multiple packets
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
                packets.each_with_index do |sp,i|
                    if (packet[:beefhook] == sp[:beefhook] and packet[:stream_id] == sp[:stream_id])
                        data += sp[:data]
                    end
                end
                b64 = Base64.decode64(data) 
                begin
                    res = JSON.parse(b64).first
                    res['beefhook'] = packet[:beefhook]
                    res['request'] = @request
                    res['beefsession'] = @request.get_hook_session_id()
                    execute(res)
                rescue JSON::ParserError => e
                    print_debug 'Network stack could not decode packet stream.'
                    print_debug 'Dumping Stream Data [base64]: '+data
                    print_debug 'Dumping Stream Data: '+b64
                end
            end
       end
    end

    #delete packets that have been reconstructed, return deleted packets
    def expunge(beefhook, stream_id)
        packets = PQ.select{ |p| p[:beefhook] == beefhook and p[:stream_id] == stream_id }
        PQ.delete_if { |p| p[:beefhook] == beefhook and p[:stream_id] == stream_id }
        return packets.sort_by { |p| p[:packet_id] }
    end

    #execute is called once a stream has been rebuilt. it searches the mounts and passes the data to the correct handler
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
    
    #assist function for getting parameter from hash
    def get_param(query, key)
      return nil if query[key].nil?
      query[key]
    end
    
  end
  
end
end
end
end
