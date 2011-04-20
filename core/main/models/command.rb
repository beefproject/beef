module BeEF
module Core
module Models
  #
  # Table stores the commands that have been sent to the Hooked Browsers.
  #
  #  Attributes:
  #
  #     - id
  #     - data
  #     - creationdate
  #     - label
  #     - instructions_sent
  #     - command_module_id
  #     - hooked_browser_id
  #
  class Command
    
    include DataMapper::Resource
  
    storage_names[:default] = 'commands'
  
    property :id, Serial
    property :data, Text
    property :creationdate, String, :length => 15, :lazy => false
    property :label, Text, :lazy => false
    property :instructions_sent, Boolean, :default => false
  
    has n, :results
  
    #
    # Save results and flag that the command has been run on the hooked browser
    #
    # @param: {String} the session_id.
    # @param: {String} the command_id.
    # @param: {String} the command friendly name.
    # @param: {String} the result of the command module.
    #
    def self.save_result(hook_session_id, command_id, command_friendly_name, result)
      # enforcing arguments types
      command_id = command_id.to_i
    
      # argument type checking
      raise Exception::TypeError, '"hook_session_id" needs to be a string' if not hook_session_id.string?
      raise Exception::TypeError, '"command_id" needs to be an integer' if not command_id.integer?
      raise Exception::TypeError, '"command_friendly_name" needs to be a string' if not command_friendly_name.string?
      raise Exception::TypeError, '"result" needs to be a hash' if not result.hash?
    
      # get the hooked browser structure and id from the database
      zombie = BeEF::Core::Models::HookedBrowser.first(:session => hook_session_id) || nil
      raise Exception::TypeError, "zombie is nil" if zombie.nil?
      raise Exception::TypeError, "zombie.id is nil" if zombie.id.nil?
      zombie_id = zombie.id
      raise Exception::TypeError, "zombie.ip is nil" if zombie.ip.nil?
      zombie_ip = zombie.ip
    
      # get the command module data structure from the database
      command = first(:id => command_id.to_i, :hooked_browser_id => zombie_id) || nil
      raise Exception::TypeError, "command is nil" if command.nil?
    
      # create the entry for the results 
      command.results.new(:hooked_browser_id => zombie_id, :data => result.to_json, :date => Time.now.to_i)
      command.save
    
      # log that the result was returned
      BeEF::Core::Logger.instance.register('Command', "The '#{command_friendly_name}' command module was successfully executed against '#{zombie_ip}'", zombie_id)
      
      # prints the event into the console
      if BeEF::Settings.console?
        print_info "The '#{command_friendly_name}' command module was successfully executed against '#{zombie_ip}'"
      end
    end
  
  end

end
end
end