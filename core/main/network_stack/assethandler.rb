#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module NetworkStack
module Handlers
    
  # @note Class defining BeEF assets 
  class AssetHandler 
    
    # @note call BeEF::Core::NetworkStack::Handlers::AssetHandler.instance
    include Singleton
    
    attr_reader :allocations, :root_dir
    
    # Starts the AssetHandler instance
    def initialize
      @allocations = {}
      @sockets = {}
      @http_server = BeEF::Core::Server.instance
      @root_dir = File.expand_path('../../../../', __FILE__)
    end

    # Binds a redirector to a mount point
    # @param [String] target The target for the redirector
    # @param [String] path An optional URL path to mount the redirector to (can be nil for a random path)
    # @return [String] URL Path of the redirector
    # @todo This function, similar to bind(), should accept a hooked browser session to limit the mounted file to a certain session etc.
    def bind_redirect(target, path=nil)
      url = build_url(path,nil)
      @allocations[url] = {'target' => target}
      @http_server.mount(url,BeEF::Core::NetworkStack::Handlers::Redirector.new(target))
      @http_server.remap
      print_info "Redirector to [" + target + "] bound to url [" + url + "]"
      url
    end

    # Binds raw HTTP to a mount point
    # @param [Integer] status HTTP status code to return
    # @param [String] headers HTTP headers as a JSON string to return
    # @param [String] body HTTP body to return
    # @param [String] path URL path to mount the asset to TODO (can be nil for random path)
    # @todo @param [Integer] count The amount of times the asset can be accessed before being automatically unbinded (-1 = unlimited)
    def bind_raw(status, header, body, path=nil, count=-1)
      url = build_url(path,nil)
      @allocations[url] = {}
      @http_server.mount(
        url,
        BeEF::Core::NetworkStack::Handlers::Raw.new(status, header, body)
      )
      @http_server.remap
      print_info "Raw HTTP bound to url [" + url + "]"
      url
    end

    # Binds a file to a mount point
    # @param [String] file File path to asset
    # @param [String] path URL path to mount the asset to (can be nil for random path)
    # @param [String] extension Extension to append to the URL path (can be nil for none)
    # @param [Integer] count The amount of times the asset can be accessed before being automatically unbinded (-1 = unlimited)
    # @return [String] URL Path of mounted asset
    # @todo This function should accept a hooked browser session to limit the mounted file to a certain session
    def bind(file, path=nil, extension=nil, count=-1)
        url = build_url(path, extension)
        @allocations[url] = {'file' => "#{root_dir}"+file, 'path' => path, 'extension' => extension, 'count' => count} 
        @http_server.mount(url, Rack::File.new(@allocations[url]['file']))
        @http_server.remap
        print_info "File [" + "#{root_dir}"+file + "] bound to url [" + url + "]"
        url
    end
    
    # Unbinds a file from a mount point
    # @param [String] url URL path of asset to be unbinded
    #TODO: check why is throwing exception
    def unbind(url)
        @allocations.delete(url)
        @http_server.unmount(url)
        @http_server.remap
        print_info "Url [" + url + "] unmounted"
    end

    # use it like: bind_socket("irc","0.0.0.0",6667)
    def bind_socket(name, host, port)
      if @sockets[name] != nil
        print_error "Bind Socket [#{name}] is already listening on [#{host}:#{port}]."
      else
        t = Thread.new {
          server = TCPServer.new(host,port)
          loop do
            Thread.start(server.accept) do |client|
              data = ""
              recv_length = 1024
              threshold = 1024 * 512
              while (tmp = client.recv(recv_length))
                data += tmp
                break if tmp.length < recv_length || tmp.length == recv_length
                # 512 KB max of incoming data
                break if data > threshold
              end
              if  data.size > threshold
                print_error "More than 512 KB of data incoming for Bind Socket [#{name}]. For security purposes client connection is closed, and data not saved."
              else
                @sockets[name] = {'thread' => t, 'data' => data}
                print_info "Bind Socket [#{name}] received [#{data.size}] bytes of data."
                print_debug "Bind Socket [#{name}] received:\n#{data}"
              end
              client.close
            end
          end
        }
        print_info "Bind socket [#{name}] listening on [#{host}:#{port}]."
      end
    end

    def get_socket_data(name)
      data = nil
      if @sockets[name] != nil
        data = @sockets[name]['data']
      else
        print_error "Bind Socket [#{name}] does not exists."
      end
      data
    end

    def unbind_socket(name)
        t = @sockets[name]['thread']
        if t.alive?
          print_debug "Thread to be killed: #{t}"
          Thread.kill(t)
          print_info "Bind Socket [#{name}] killed."
        else
          print_info "Bind Socket [#{name}] ALREADY killed."
        end
    end

    # Builds a URL based on the path and extension, if neither are passed a random URL will be generated
    # @param [String] path URL Path defined by bind()
    # @param [String] extension Extension defined by bind()
    # @param [Integer] length The amount of characters to be used when generating a random URL
    # @return [String] Generated URL
    def build_url(path, extension, length=20)
        url = (path == nil) ? '/'+rand(36**length).to_s(36) : path
        url += (extension == nil) ? '' : '.'+extension
        url
    end

    # Checks if the file is allocated, if the file isn't return true to pass onto FileHandler.
    # @param [String] url URL Path of mounted file
    # @return [Boolean] Returns true if the file is mounted
    def check(url)
        if @allocations.has_key?(url)
            count = @allocations[url]['count']
            if count == -1
                return true
            end
            if count > 0 
                if (count - 1) == 0
                    unbind(url)
                else
                    @allocations[url]['count'] = count - 1
                end
                return true
            end
        end
        false
    end
   
   private
   @http_server
   @allocations

  end
  
end
end
end
end
