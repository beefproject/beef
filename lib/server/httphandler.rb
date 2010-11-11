module BeEF
  
  class HttpHandler < WEBrick::HTTPServlet::AbstractServlet
    
    attr_reader :guard
    
    #
    #
    #
    def initialize(config, klass)
      super
      @guard = Mutex.new
      @klass = BeEF::UI.const_get(klass.to_s.capitalize)
    end
    
    def do_GET(request, response)
      @request = request
      @response = response
      
      controller = nil
      @guard.synchronize {
        controller = @klass.new
        controller.run(@request, @response)
      }
      
      response.header.replace(controller.headers)
      response.body = controller.body.to_s
    end
    
    private
    
    @request
    @response
    
    alias do_POST do_GET
  end
  
end