module BeEF
  
  #DynamicHanlder is used reconstruct segmented traffic from the zombies

  class DynamicHandler < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard

    #holds packet queue
    PQ = Array.new() 
   
    #obtain dynamic mount points from HttpHookServer
    MOUNTS = BeEF::HttpHookServer.instance.mounts

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
                #better way than sorting the entire array?
                PQ.sort_by { |s| s[:packet_id] }
                data = ''
                PQ.each_with_index do |sp,i|
                    if (packet[:beefhook] == sp[:beefhook] and packet[:stream_id] == sp[:stream_id])
                        data += sp[:data]
                    end
                end
                
                data = JSON.parse(Base64.decode64(data)).first
                data['beefhook'] = packet[:beefhook]
                data['request'] = @request
                data['beefsession'] = @request.get_hook_session_id()
                expunge(packet[:beefhook], packet[:stream_id])
                execute(data)
            end
       end
    end

    #delete packets that have been reconstructed
    def expunge(beefhook, stream_id)
        PQ.delete_if { |p| p[:beefhook] == beefhook and p[:stream_id] == stream_id }
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
