module BeEF
  
  #
  # This module contains a list of utils functions to use
  # when writing commands.
  #
  module CommandUtils
    
    # Format a string to support multiline in javascript.
    def format_multiline(text); text.gsub(/\n/, '\n'); end
    
  end
  
  #
  # The Command Module Context is being used when evaluating code in eruby.
  # In other words, we use that code to add funky functions to the
  # javascript templates of our commands.
  #
  class CommandContext < Erubis::Context
    include BeEF::CommandUtils
    
    def initialize(hash=nil); 
      super(hash); 
    end
    
  end
  
  #
  # This class is the base class for all command modules in the framework.
  #
  # Two instances of this object are created during the execution of command module.
  #
  class Command
  
    attr_reader :info, :datastore, :path, :default_command_url, :beefjs_components, :friendlyname
    attr_accessor :zombie, :command_id, :session_id, :target
    
    include BeEF::CommandUtils
    
    BD = BeEF::Models::BrowserDetails
    
    UNKNOWN = BeEF::Constants::Browsers::UNKNOWN
    ALL     = BeEF::Constants::Browsers::ALL
    IE      = BeEF::Constants::Browsers::IE
    S       = BeEF::Constants::Browsers::S
    FF      = BeEF::Constants::Browsers::FF
    C       = BeEF::Constants::Browsers::C
    
    VERIFIED_WORKING =     BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_WORKING
    VERIFIED_NOT_WORKING = BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_NOT_WORKING
    VERIFIED_USER_NOTIFY = BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_USER_NOTIFY
    VERIFIED_UNKNOWN =     BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_UNKNOWN
    
    # Super class controller
    def initialize(info)
      @info = info
      @datastore = @info['Data'] || nil
      @friendlyname = @info['Name'] || nil
      @target = @info['Target'] || nil
      @output = ''
      @path = @info['File'].sub(BeEF::HttpHookServer.instance.root_dir, '')
      @default_command_url = '/command/'+(File.basename @path, '.rb')+'.js'
      @id = BeEF::Models::CommandModule.first(:path => @info['File']).object_id
      @use_template = false
      @auto_update_zombie = false
      @results = {}
      @beefjs_components = {}
    end
    
    # This function is called just before the intructions are sent to hooked browser.
    # The derived class can use this function to update params used in the command module.
    def pre_send; 
    end
    
    # Callback method. This function is called when the hooked browser sends results back.
    def callback; end
    
    # If the command requires some data to be sent back, this function will process them.
    def process_zombie_response(head, params); end
    
    # Returns true if the command needs configurations to work. False if not.
    def needs_configuration?; !@datastore.nil?; end
    
    # Returns information about the command in a JSON format.
    def to_json
       {
        'Name'          => info['Name'],
        'Description'   => info['Description'],
        'Category'      => info['Category'],
        'Data'          => info['Data']            
      }.to_json
    end
    
    # Builds the 'datastore' attribute of the command which is used to generate javascript code.
    def build_datastore(data); 
      @datastore = JSON.parse(data); 
    end
    
    # Sets the datastore for the callback function. This function is meant to be called by the CommandHandler
    #
    #  build_callback_datastore(http_params, http_header)
    #
    def build_callback_datastore(http_params, http_header)
      
      @datastore = {'http_headers' => {}} # init the datastore
      
      # get, check and add the http_params to the datastore
      http_params.keys.each {|http_params_key|
        raise WEBrick::HTTPStatus::BadRequest, "http_params_key is invalid" if not BeEF::Filter.is_valid_command_module_datastore_key?(http_params_key)
        http_params_value = Erubis::XmlHelper.escape_xml(http_params[http_params_key])
        raise WEBrick::HTTPStatus::BadRequest, "http_params_value is invalid" if not BeEF::Filter.is_valid_command_module_datastore_param?(http_params_value)
        @datastore[http_params_key] = http_params_value # add the checked key and value to the datastore
      }

      # get, check and add the http_headers to the datastore
      http_header.keys.each { |http_header_key|
        raise WEBrick::HTTPStatus::BadRequest, "http_header_key is invalid" if not BeEF::Filter.is_valid_command_module_datastore_key?(http_header_key)
        http_header_value = Erubis::XmlHelper.escape_xml(http_header[http_header_key][0])
        raise WEBrick::HTTPStatus::BadRequest, "http_header_value is invalid" if not BeEF::Filter.is_valid_command_module_datastore_param?(http_header_value)
        @datastore['http_headers'][http_header_key] = http_header_value # add the checked key and value to the datastore
      }
      
    end

    # set the target details 
    # this function is used when determining the code of the node icon
    def set_target(definition)

      @target = [] if not @target
      @target.push(definition)

    end

    # verify whether this command module has been checked against the target browser
    # this function is used when determining the code of the node icon
    def verify_target

      return VERIFIED_UNKNOWN if not @target # no target specified in the module

      # loop through each definition and check it
      @target.each {|definition| 
        return definition['verified_status'] if test_target(definition)
      }

      return VERIFIED_UNKNOWN

    end
    
    # test if the target definition matches the hooked browser
    # this function is used when determining the code of the node icon
    def test_target_attribute(hb_attr_name, hb_attr_ver, target_attr_name, target_attr_max_ver, target_attr_min_ver)

      # check if wild cards are set
      return true if not target_attr_name
      return true if target_attr_name.nil?
      return true if target_attr_name.eql? ALL

      # can't answer based on hb_attr_name
      return false if not hb_attr_name
      return false if hb_attr_name.nil?
      return false if hb_attr_name.eql? UNKNOWN
      
      # check if the attribute is targeted
      return false if not target_attr_name.eql? hb_attr_name
      
      # assume that the max version and min version were purposefully excluded 
      return true if target_attr_max_ver.nil? && target_attr_min_ver.nil?
      
      # check if the framework can detect hb version
      return false if hb_attr_ver.eql? 'UNKNOWN'
      
      # check the version number is within range
      return false if hb_attr_ver.to_f > target_attr_max_ver.to_f
      return false if hb_attr_ver.to_f < target_attr_min_ver.to_f
      
      # all the checks passed
      true
    end
    
    # test if the target definition matches the hooked browser
    # this function is used when determining the code of the node icon
    def test_target(target_definition)
      
      # if the definition is nill we don't know
      return false if target_definition.nil?
      
      # check if the browser is a target
      hb_browser_name = get_browser_detail('BrowserName')
      hb_browser_version = get_browser_detail('BrowserVersion')
      target_browser_name = target_definition['browser_name']
      target_browser_max_ver = target_definition['browser_maxver']
      target_browser_min_ver = target_definition['browser_minver']
      browser_match = test_target_attribute(hb_browser_name, hb_browser_version, target_browser_name, target_browser_max_ver, target_browser_min_ver)

      # check if the operating system is a target
      hb_os_name = get_browser_detail('OSName')
      target_os_name = target_definition['os_name']
      os_match =  test_target_attribute(hb_os_name, nil, target_os_name, nil, nil)
      
      return browser_match && os_match

    end
    
    # Store the browser detail in the database. 
    def set_browser_detail(key, value)
      raise WEBrick::HTTPStatus::BadRequest, "@session_id is invalid" if not BeEF::Filter.is_valid_hook_session_id?(@session_id)
      BD.set(@session_id, key, value)
    end
    
    # Get the browser detail from the database. 
    def get_browser_detail(key)
      raise WEBrick::HTTPStatus::BadRequest, "@session_id is invalid" if not BeEF::Filter.is_valid_hook_session_id?(@session_id)
      BD.get(@session_id, key)
    end
    
    # Tells the framework that the command module will be using a template file.
    def use_template!;
      tpl = @info['File'].sub(/.rb$/, '.js')
      @template = tpl if File.exists? tpl
      
      @use_template = true;
    end
    
    # Returns true if the command uses a template. False if not.
    def use_template?; @use_template; end
    
    # Returns the output of the command. These are the actual instructions sent to the browser.
    def output
      if use_template? # and @template
        raise WEBrick::HTTPStatus::BadRequest, "@template is nil" if @template.nil?
        raise WEBrick::HTTPStatus::BadRequest, "@template file does not exist" if not File.exists? @template
        
        @eruby = Erubis::FastEruby.new(File.read(@template)) 
        
        if @datastore
          @datastore['command_url'] = BeEF::HttpHookServer.instance.get_command_url(@default_command_url)
          @datastore['command_id'] = @command_id
          
          command_context = BeEF::CommandContext.new
          @datastore.each{|k,v| 
            command_context[k] = v
          }
          
          @output = @eruby.evaluate(command_context)
        else
          @ouput = @eruby.result()
        end
      end
      
      @output
    end
    
    # Returns the results for the zombie.
    def get_results
      return '' if @results.length.eql? 0
      
      @results.to_json
    end

    # Saves the results received from the zombie.
    def save(results); 
      @results = results; 
    end
    
    # Tells the framework to load a specific module of the BeEFJS library that
    # the command will be using.
    #
    #  use 'beef.net.local'
    #  use 'beef.encode.base64'
    #
    def use(component)
      return if @beefjs_components.include? component
      
      component_path = '/'+component
      component_path.gsub!(/beef./, '')
      component_path.gsub!(/\./, '/')
      component_path.replace "#{$root_dir}/modules/beefjs/#{component_path}.js"
      
      raise "Invalid beefjs component for command module #{@path}" if not File.exists?(component_path)
      
      @beefjs_components[component] = component_path
    end
  
    private
    
    @use_template
    @eruby
    @update_zombie
    @results
    
  end
  
end
