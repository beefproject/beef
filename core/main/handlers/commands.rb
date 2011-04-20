module BeEF
module Core
module Handlers
  
  class Commands
    
    include BeEF::Core::Handlers::Modules::BeEFJS
    include BeEF::Core::Handlers::Modules::Command
    
    attr_reader :guard
    @data = {}
    
    def initialize(data, kclass)
      @guard = Mutex.new
      @kclass = BeEF::Core::Command.const_get(kclass.capitalize)
      @data = data
      setup()
    end
    
    def setup()
      @http_params = @data['request'].query  # used to populate datastore
      @http_header = @data['request'].header # used to populate datastore
      @http_header['referer'] ||= '' # used to populate datastore
      
      # get and check command id from the request
      command_id  = get_param(@data, 'cid')
      # ruby filter needs to be updated to detect fixnums not strings
      command_id = command_id.to_s()
      raise WEBrick::HTTPStatus::BadRequest, "command_id is invalid" if not BeEF::Filters.is_valid_command_id?(command_id.to_s())   

      # get and check session id from the request
      beefhook = get_param(@data, 'beefhook')
      raise WEBrick::HTTPStatus::BadRequest, "beefhook is invalid" if not BeEF::Filters.is_valid_hook_session_id?(beefhook)   

      @guard.synchronize {
        # create the command module to handle the response
        command = @kclass.new # create the commamd module 
        command.build_callback_datastore(@http_params, @http_header) # build datastore from the response
        command.session_id = beefhook 
        command.callback # call the command module's callback function - it will parse and save the results

        # get/set details for datastore and log entry
        command_friendly_name = command.friendlyname
        raise WEBrick::HTTPStatus::BadRequest, "command friendly name empty" if command_friendly_name.empty?
        command_results = get_param(@data, 'results')
        raise WEBrick::HTTPStatus::BadRequest, "command results empty" if command_results.empty?
        # save the command module results to the datastore and create a log entry
        command_results = {'type' => command_results.class, 'data' => command_results}
        BeEF::Core::Models::Command.save_result(beefhook, command_id, command_friendly_name, command_results) 
      }
    end
    
    def get_param(query, key)
        return (query.class == Hash and query.has_key?(key)) ? query[key] : nil
    end

  end
    
  
end
end
end
