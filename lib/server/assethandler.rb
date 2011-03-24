module BeEF
  
  #
  # Class defining BeEF assets 
  #
  class AssetHandler 
    
    # call BeEF::AssetHanlder.instance
    include Singleton
    
    attr_reader :allocations, :root_dir
    
    def initialize
      @allocations = {}
      @http_server = BeEF::HttpHookServer.instance
      @root_dir = File.expand_path('../../../', __FILE__)
    end

    #
    # Binds a file to a mount point
    #
    def bind(file, path=nil, extension=nil, count=-1)
        url = buildURL(path, extension) 
        @allocations[url] = {'file' => "#{root_dir}"+file, 'path' => path, 'extension' => extension, 'count' => count} 
        @http_server.mount(url, true, BeEF::FileHandler, @allocations[url]['file'])
        puts @allocations
        return url
    end
    
    #
    # Unbinds a file from a mount point
    #
    def unbind(url)
        @allocations.delete(url)
        @http_server.unmount(url, true)
    end

    #
    # Builds a URL based on the path and extention, if neither are passed a random URL will be generated
    #
    def buildURL(path, extension, length=20)
        url = (path == nil) ? '/'+rand(36**length).to_s(36) : path;
        url += (extension == nil) ? '' : '.'+extension;
        return url
    end

    #
    # Checks if the file is allocated, if the file isn't return true to pass onto FileHandler.
    #
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
        return false
    end
   
   private
   @http_server
   @allocations

  end
  
end
