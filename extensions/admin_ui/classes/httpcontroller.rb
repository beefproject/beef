#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module AdminUI
    
  #
  # Handle HTTP requests and call the relevant functions in the derived classes
  #
  class HttpController
    
    attr_accessor :headers, :status, :body, :paths, :currentuser, :params
    
    C = BeEF::Core::Models::Command
    CM = BeEF::Core::Models::CommandModule
    Z = BeEF::Core::Models::HookedBrowser
    
    #
    # Class constructor. Takes data from the child class and populates itself with it.
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
    # Handle HTTP requests and call the relevant functions in the derived classes
    #
    def run(request, response)
      @request = request
      @params = request.params
      @session = BeEF::Extension::AdminUI::Session.instance      
      auth_url = '/ui/authentication'
      
      # test if session is unauth'd and whether the auth functionality is requested
      if not @session.valid_session?(@request) and not self.class.eql?(BeEF::Extension::AdminUI::Controllers::Authentication)
        @body = ''
        @status = 302
        @headers = {'Location' => auth_url}
        return
      end
      
      # get the mapped function (if it exists) from the derived class
      path = request.path_info
      (print_error "path is invalid";return) if not BeEF::Filters.is_valid_path_info?(path)
      function = @paths[path] || @paths[path + '/'] # check hash for '<path>' and '<path>/'
      (print_error "path does not exist";return) if function.nil?
      
      # call the relevant mapped function
      function.call

      # build the template filename and apply it - if the file exists
      function_name = function.name # used for filename
      class_s = self.class.to_s.sub('BeEF::Extension::AdminUI::Controllers::', '').downcase # used for directory name
      template_ui = "#{$root_dir}/extensions/admin_ui/controllers/#{class_s}/#{function_name}.html"
      @eruby = Erubis::FastEruby.new(File.read(template_ui)) if File.exists? template_ui # load the template file
      @body = @eruby.result(binding()) if not @eruby.nil? # apply template and set the response

      # set appropriate content-type 'application/json' for .json files
      @headers['Content-Type']='application/json; charset=UTF-8' if request.path =~ /\.json$/

      # set content type
      if @headers['Content-Type'].nil?
        @headers['Content-Type']='text/html; charset=UTF-8' # default content and charset type for all pages
        @headers['Content-Type']='application/json; charset=UTF-8' if request.path =~ /\.json$/
      end

    end

    # Constructs a redirect script
    def script_redirect(location) "<script> document.location=\"#{location}\"</script>" end
    
    # Constructs a html script tag
    def script_tag(filename) "<script src=\"#{$url}/ui/media/javascript/#{filename}\" type=\"text/javascript\"></script>" end
    
    # Constructs a html stylesheet tag
    def stylesheet_tag(filename) "<link rel=\"stylesheet\" href=\"#{$url}/ui/media/css/#{filename}\" type=\"text/css\" />" end

    # Constructs a hidden html nonce tag
    def nonce_tag 
      @session = BeEF::Extension::AdminUI::Session.instance
      "<input type=\"hidden\" name=\"nonce\" id=\"nonce\" value=\"" + @session.get_nonce + "\"/>"
    end

    private
    
    @eruby
    
    # Unescapes a URL-encoded string.
    def unescape(s); s.tr('+', ' ').gsub(/%([\da-f]{2})/in){[$1].pack('H*')} end
    
  end

end
end
end
