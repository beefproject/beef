#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
  module Core

    # @note This module contains a list of utils functions to use when writing commands
    module CommandUtils

      # Format a string to support multiline in javascript.
      # @param [String] text String to convert
      # @return [String] Formatted string
      def format_multiline(text); text.gsub(/\n/, '\n'); end

    end



    # @note The Command Module Context is being used when evaluating code in eruby.
    #   In other words, we use that code to add funky functions to the
    #   javascript templates of our commands.
    class CommandContext < Erubis::Context
      include BeEF::Core::CommandUtils

      # Constructor
      # @param [Hash] hash
      def initialize(hash=nil);
      super(hash);
      end

    end

    # @note This class is the base class for all command modules in the framework.
    #   Two instances of this object are created during the execution of command module.
    class Command

      attr_reader :datastore, :path, :default_command_url, :beefjs_components, :friendlyname
      attr_accessor :zombie, :command_id, :session_id

      include BeEF::Core::CommandUtils
      include BeEF::Core::Constants::Browsers
      include BeEF::Core::Constants::CommandModule

      # Super class controller
      # @param [String] key command module key
      def initialize(key)
        config = BeEF::Core::Configuration.instance

        @key = key
        @datastore = {}
        @friendlyname = config.get("beef.module.#{key}.name")
        @output = ''
        @path = config.get("beef.module.#{key}.path")
        @default_command_url = config.get("beef.module.#{key}.mount")
        @id = config.get("beef.module.#{key}.db.id")
        @auto_update_zombie = false
        @results = {}
        @beefjs_components = {}
      end

      # This function is called just before the instructions are sent to hooked browser.
      def pre_send; end

      # Callback method. This function is called when the hooked browser sends results back.
      def callback; end

      # If the command requires some data to be sent back, this function will process them.
      # @param [] head
      # @param [Hash] params Hash of parameters
      # @todo Determine argument "head" type
      def process_zombie_response(head, params); end

      # Returns true if the command needs configurations to work. False if not.
      # @deprecated This command should not be used since the implementation of the new configuration system
      def needs_configuration?; !@datastore.nil?; end

      # Returns information about the command in a JSON format.
      # @return [String] JSON formatted string
      def to_json
        {
            'Name'          => @friendlyname,
            'Description'   => BeEF::Core::Configuration.instance.get("beef.module.#{@key}.description"),
            'Category'      => BeEF::Core::Configuration.instance.get("beef.module.#{@key}.category"),
            'Data'          => BeEF::Module.get_options(@key)
        }.to_json
      end

      # Builds the 'datastore' attribute of the command which is used to generate javascript code.
      # @param [Hash] data Data to be inserted into the datastore
      # @todo Confirm argument "data" type
      def build_datastore(data);
      @datastore = JSON.parse(data)
      end

      # Sets the datastore for the callback function. This function is meant to be called by the CommandHandler
      # @param [Hash] http_params HTTP parameters
      # @param [Hash] http_headers HTTP headers
      def build_callback_datastore(http_params, http_headers, result, command_id, beefhook)
        @datastore = {'http_headers' => {}} # init the datastore

        # get, check and add the http_params to the datastore
        http_params.keys.each { |http_params_key|
          (print_error 'http_params_key is invalid';return) if not BeEF::Filters.is_valid_command_module_datastore_key?(http_params_key)
          http_params_value = Erubis::XmlHelper.escape_xml(http_params[http_params_key])
          (print_error 'http_params_value is invalid';return) if not BeEF::Filters.is_valid_command_module_datastore_param?(http_params_value)
          @datastore[http_params_key] = http_params_value # add the checked key and value to the datastore
        }

        # get, check and add the http_headers to the datastore
        http_headers.keys.each { |http_header_key|
          (print_error 'http_header_key is invalid';return) if not BeEF::Filters.is_valid_command_module_datastore_key?(http_header_key)
          http_header_value = Erubis::XmlHelper.escape_xml(http_headers[http_header_key][0])
          (print_error 'http_header_value is invalid';return) if not BeEF::Filters.is_valid_command_module_datastore_param?(http_header_value)
          @datastore['http_headers'][http_header_key] = http_header_value # add the checked key and value to the datastore
        }
        @datastore['results'] = result
        @datastore['cid'] = command_id
        @datastore['beefhook'] = beefhook		
      end

      # Returns the output of the command. These are the actual instructions sent to the browser.
      # @return [String] The command output
      def output
        f = @path+'command.js'
        (print_error "#{f} file does not exist";return) if not File.exists? f

        command = BeEF::Core::Models::Command.first(:id => @command_id)

        @eruby = Erubis::FastEruby.new(File.read(f))

        data = BeEF::Core::Configuration.instance.get("beef.module.#{@key}")
        cc = BeEF::Core::CommandContext.new
        cc['command_url'] = @default_command_url
        cc['command_id'] = @command_id
        JSON.parse(command['data']).each{|v|
          cc[v['name']] = v['value']
        }
        if self.respond_to?(:execute)
          self.execute
        end
        @output = @eruby.evaluate(cc)

        @output
      end

      # Saves the results received from the hooked browser
      # @param [Hash] results Results from hooked browser
      def save(results)
        @results = results
      end

      # If nothing else than the file is specified, the function will map the file to a random path without any extension.
      # @param [String] file File to be mounted
      # @param [String] path URL path to mounted file
      # @param [String] extension URL extension
      # @param [Integer] count The amount of times this file can be accessed before being automatically unmounted
      # @deprecated This function is possibly deprecated in place of the API
      def map_file_to_url(file, path=nil, extension=nil, count=1)
        return  BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(file, path, extension, count)
      end

      # Tells the framework to load a specific module of the BeEFJS library that the command will be using.
      # @param [String] component String of BeEFJS component to load
      # @note Example: use 'beef.net.local'
      def use(component)
        return if @beefjs_components.include? component

        component_path = '/'+component
        component_path.gsub!(/beef./, '')
        component_path.gsub!(/\./, '/')
        component_path.replace "#{$root_dir}/core/main/client/#{component_path}.js"

        raise "Invalid beefjs component for command module #{@path}" if not File.exists?(component_path)

        @beefjs_components[component] = component_path
      end

      # @todo Document
      def oc_value(name)
        option =  BeEF::Core::Models::OptionCache.first(:name => name)
        return nil if not option
        return option.value
      end

      # @todo Document
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
