#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module Core


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
    include BeEF::Core::CommandUtils
    
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
  
    attr_reader :datastore, :path, :default_command_url, :beefjs_components, :friendlyname
    attr_accessor :zombie, :command_id, :session_id
    
    include BeEF::Core::CommandUtils
    include BeEF::Core::Constants::Browsers
    include BeEF::Core::Constants::CommandModule

    # Super class controller
    def initialize(key)
      get_extensions
      config = BeEF::Core::Configuration.instance

      @key = key
      @datastore = {}
      @friendlyname = config.get("beef.module.#{key}.name")
      @output = ''
      @path = config.get("beef.module.#{key}.path")
      @default_command_url = config.get("beef.module.#{key}.mount")
      @id = config.get("beef.module.#{key}.id")
      @auto_update_zombie = false
      @results = {}
      @beefjs_components = {}
    end
    
    #
    # Uses the API to include all the code from extensions that need to add
    # methods, constants etc to that class.
    #
    # See BeEF::API::Command for examples.
    #
    def get_extensions
      BeEF::API::Command.extended_in_modules.each do |mod|
        self.class.send(:include, mod)
      end
    end
    
    #
    # This function is called just before the intructions are sent to hooked browser.
    # The derived class can use this function to update params used in the command module.
    #
    def pre_send; end
    
    #
    # Callback method. This function is called when the hooked browser sends results back.
    #
    def callback; end
    
    #
    # If the command requires some data to be sent back, this function will process them.
    #
    def process_zombie_response(head, params); end
    
    #
    # Returns true if the command needs configurations to work. False if not.
    #
    def needs_configuration?; !@datastore.nil?; end
    
    #
    # Returns information about the command in a JSON format.
    #
    def to_json
       {
        'Name'          => @friendlyname,
        'Description'   => BeEF::Core::Configuration.instance.get("beef.module.#{@key}.description"),
        'Category'      => BeEF::Core::Configuration.instance.get("beef.module.#{@key}.category"),
        'Data'          => BeEF::Module.get_options(@key)            
      }.to_json
    end
    
    #
    # Builds the 'datastore' attribute of the command which is used to generate javascript code.
    #
    def build_datastore(data); 
      @datastore = JSON.parse(data)
    end
    
    #
    # Sets the datastore for the callback function. This function is meant to be called by the CommandHandler
    #
    #  build_callback_datastore(http_params, http_header)
    #
    def build_callback_datastore(http_params, http_header)
      @datastore = {'http_headers' => {}} # init the datastore
      
      # get, check and add the http_params to the datastore
      http_params.keys.each { |http_params_key|
        raise WEBrick::HTTPStatus::BadRequest, "http_params_key is invalid" if not BeEF::Filters.is_valid_command_module_datastore_key?(http_params_key)
        http_params_value = Erubis::XmlHelper.escape_xml(http_params[http_params_key])
        raise WEBrick::HTTPStatus::BadRequest, "http_params_value is invalid" if not BeEF::Filters.is_valid_command_module_datastore_param?(http_params_value)
        @datastore[http_params_key] = http_params_value # add the checked key and value to the datastore
      }

      # get, check and add the http_headers to the datastore
      http_header.keys.each { |http_header_key|
        raise WEBrick::HTTPStatus::BadRequest, "http_header_key is invalid" if not BeEF::Filters.is_valid_command_module_datastore_key?(http_header_key)
        http_header_value = Erubis::XmlHelper.escape_xml(http_header[http_header_key][0])
        raise WEBrick::HTTPStatus::BadRequest, "http_header_value is invalid" if not BeEF::Filters.is_valid_command_module_datastore_param?(http_header_value)
        @datastore['http_headers'][http_header_key] = http_header_value # add the checked key and value to the datastore
      } 
    end
    
    #
    # Returns the output of the command. These are the actual instructions sent to the browser.
    #
    def output
        f = @path+'command.js'
        raise WEBrick::HTTPStatus::BadRequest, "#{f} file does not exist" if not File.exists? f
        
        @eruby = Erubis::FastEruby.new(File.read(f)) 
        
        if @datastore
          @datastore['command_url'] = BeEF::Core::Server.instance.get_command_url(@default_command_url)
          @datastore['command_id'] = @command_id
          
          command_context = BeEF::Core::CommandContext.new
          @datastore.each{|k,v| 
            command_context[k] = v
          }
          
          @output = @eruby.evaluate(command_context)
        else
          @ouput = @eruby.result()
        end
      
      @output
    end
    
    #
    # Saves the results received from the zombie.
    #
    def save(results); 
      @results = results; 
    end

    # If nothing else than the file is specified, the function will map the file to a random path
    # without any extension.
    def map_file_to_url(file, path=nil, extension=nil, count=1)
           return  BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(file, path, extension, count)
    end
    
    #
    # Tells the framework to load a specific module of the BeEFJS library that
    # the command will be using.
    #
    #  Example:
    #
    #   use 'beef.net.local'
    #   use 'beef.encode.base64'
    #
    def use(component)
      return if @beefjs_components.include? component
      
      component_path = '/'+component
      component_path.gsub!(/beef./, '')
      component_path.gsub!(/\./, '/')
      component_path.replace "#{$root_dir}/core/main/client/#{component_path}.js"
      
      raise "Invalid beefjs component for command module #{@path}" if not File.exists?(component_path)
      
      @beefjs_components[component] = component_path
    end

    def oc_value(name)
        option =  BeEF::Core::Models::OptionCache.first(:name => name)
		return nil if not option
      	return option.value
	end

	def apply_defaults()
	    @datastore.each { |opt|
		    opt["value"] = oc_value(opt["name"]) || opt["value"]
		}
	end
  
    private
    
    @use_template
    @eruby
    @update_zombie
    @results
    
  end
  

end
end
