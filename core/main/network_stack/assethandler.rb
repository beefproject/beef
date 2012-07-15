#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
        print_error "Thread [#{name}] is already listening on [#{host}:#{port}]."
      else
        t = Thread.new {
          server = TCPServer.new(host,port)
          loop do
            client = server.accept
            client.close
          end
        }
        @sockets[name] = t
        print_info "Thread [#{name}] listening on [#{host}:#{port}]."
      end
    end

    def unbind_socket(name)
      t = @sockets[name]
      Thread.kill(t)
      print_info "Thread [#{name}] killed."
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
