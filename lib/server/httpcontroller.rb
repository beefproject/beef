require 'erubis'

module BeEF
  
  #
  #
  #
  class HttpController
    
    attr_accessor :headers, :status, :body, :paths, :currentuser, :params
    
    C = BeEF::Models::Command
    E = BeEF::Models::CommandModule
    Z = BeEF::Models::Zombie
    
    #
    # Class constructor. Takes data from the child class and populates
    # itself with it.
    #
    def initialize(data = {})
      @erubis = nil
      @status = 200 if data['status'].nil?

      @headers = {'Content-Type' => 'text/html; charset=UTF-8'} if data['headers'].nil?

      if data['paths'].nil? and self.methods.include? "index"
        @paths = {'index' => '/'} 
      else
        @paths = data['paths']
      end
    end
    
    #
    #
    #
    def run(request, response)
      @request = request
      @params = request.query
      @session = BeEF::UI::Session.instance      
      auth_url = '/ui/authentication'

      # test if session is unauth'd and whether the auth functionality is requested
      if not @session.valid_session?(@request) and not self.class.eql?(BeEF::UI::Authentication)
        
        # request is unauthenicated so redirect to auth page
        @body = page_redirect(auth_url)
        return
        
      end

      # search for matching path and get the function to call
      function = get_path_function(request.path_info)
      raise WEBrick::HTTPStatus::BadRequest, "path does not exist" if function.nil?

      eval "self.#{function}"

      # use template
      class_s = self.class.to_s.sub('BeEF::UI::', '').downcase

      template_ui = "#{$root_dir}/lib/ui/#{class_s}/#{function}.html"
      @eruby = Erubis::FastEruby.new(File.read(template_ui)) if File.exists? template_ui

      template_module = "#{$root_dir}/modules/plugins/#{class_s}/#{function}.html"
      @eruby = Erubis::FastEruby.new(File.read(template_module)) if File.exists? template_module

      @body = @eruby.result(binding()) if not @eruby.nil?

      if @headers['Content-Type'].nil?
        @headers['Content-Type']='text/html; charset=UTF-8' # default content and charset type for all pages
        @headers['Content-Type']='application/json; charset=UTF-8' if request.path =~ /.json$/
      end

    end

    #
    # get the function mapped to path_info
    #
    def get_path_function(path_info) 

      return nil if @paths.nil?

      # search the paths
      @paths.each{ |function, path|
        return function if path.eql? path_info
        return function if path.eql? path_info + '/'
      }

      nil
    end

    # Forges a redirect page
    def page_redirect(location) "<html><head></head><body>" + script_redirect(location) + "</body>" end
    
    # Forges a redirect script
    def script_redirect(location) "<script> document.location=\"#{location}\"</script>" end
    
    # Forges a html script tag
    def script_tag(filename) "<script src=\"#{$url}/ui/public/javascript/#{filename}\" type=\"text/javascript\"></script>" end
    
    # Forges a html stylesheet tag
    def stylesheet_tag(filename) "<link rel=\"stylesheet\" href=\"#{$url}/ui/public/css/#{filename}\" type=\"text/css\" />" end

    # Forges a hidden html nonce tag
    def nonce_tag 
      @session = BeEF::UI::Session.instance
      "<input type=\"hidden\" name=\"nonce\" id=\"nonce\" value=\"" + @session.get_nonce + "\"/>"
    end

    private
    
    @eruby
    
    # Unescapes a URL-encoded string.
    def unescape(s); s.tr('+', ' ').gsub(/%([\da-f]{2})/in){[$1].pack('H*')} end
    
  end

end