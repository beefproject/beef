module BeEF
  
  class CommandHandler < WEBrick::HTTPServlet::AbstractServlet
    
    include BeEF::Server::Modules::Common
    
    attr_reader :guard
    
    def initialize(config, kclass)
      @guard = Mutex.new
      @kclass = BeEF::Modules::Commands.const_get(kclass.capitalize)
    end
    
    def do_POST(request, response)
      @body = ''
      @request = request
      @response = response
      @http_params = @request.query  # used to populate datastore
      @http_header = @request.header # used to populate datastore
      @http_header['referer'] ||= '' # used to populate datastore

      # get and check command id from the request
      command_id  = @request.get_command_id()
      raise WEBrick::HTTPStatus::BadRequest, "command_id is invalid" if not BeEF::Filter.is_valid_command_id?(command_id)   

      # get and check session id from the request
      hook_session_id = request.get_hook_session_id()
      raise WEBrick::HTTPStatus::BadRequest, "hook_session_id is invalid" if not BeEF::Filter.is_valid_hook_session_id?(hook_session_id)   

      @guard.synchronize {
        # create the command module to handle the response
        command = @kclass.new # create the commamd module 
        command.build_callback_datastore(@http_params, @http_header) # build datastore from the response
        command.session_id = hook_session_id
        command.callback # call the command module's callback function - it will parse and save the results

        # get/set details for datastore and log entry
        command_friendly_name = command.friendlyname
        raise WEBrick::HTTPStatus::BadRequest, "command friendly name empty" if command_friendly_name.empty?
        command_results = command.get_results()
        raise WEBrick::HTTPStatus::BadRequest, "command results empty" if command_results.empty?

        # save the command module results to the datastore and create a log entry
        BeEF::Models::Command.save_result(hook_session_id, command_id, command_friendly_name, command_results) 
      }

      response.set_no_cache
      response.header['Content-Type'] = 'text/javascript' 
      response.header['Access-Control-Allow-Origin'] = '*'
      response.header['Access-Control-Allow-Methods'] = 'POST'
      response.body = @body
    end
    
    alias do_GET do_POST
    
    private
    
    @request
    @response
    
  end
  
end