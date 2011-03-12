module BeEF
module Models

class Command 
  
  include DataMapper::Resource
  
  storage_names[:default] = 'commands'
  
  property :id, Serial
  property :data, Text
  property :creationdate, String, :length => 15, :lazy => false
  property :label, Text, :lazy => false
  property :instructions_sent, Boolean, :default => false
  
  has n, :results
  has n, :autoloadings
  
  #
  # Save results and flag that the command has been run on the hooked browser
  #
  # @param: {String} the session_id. Must have been checked with BeEF::Filter.is_valid_hook_session_id?(hook_session_id) before use in this function.
  # @param: {String} the command_id. Must have been checked with BeEF::Filter.is_valid_commmamd_id?(command_id) before use in this function.
  # @param: {String} the command friendly name. Must have been checked with command_friendly_name.empty? before use in this function.
  # @param: {String} the result of the command module. Must have been checked with result.empty? before use in this function.
  #
  def self.save_result(hook_session_id, command_id, command_friendly_name, result)
    
    # get the hooked browser structure and id from the database
    zombie = BeEF::Models::Zombie.first(:session => hook_session_id) || nil
    raise WEBrick::HTTPStatus::BadRequest, "zombie is nil" if zombie.nil?
    raise WEBrick::HTTPStatus::BadRequest, "zombie.id is nil" if zombie.id.nil?
    zombie_id = zombie.id
    raise WEBrick::HTTPStatus::BadRequest, "zombie.ip is nil" if zombie.ip.nil?
    zombie_ip = zombie.ip

    # get the command module data structure from the database
    command = first(:id => command_id.to_i, :zombie_id => zombie_id) || nil
    raise WEBrick::HTTPStatus::BadRequest, "command is nil" if command.nil?

    # create the entry for the results 
    command.results.new(:zombie_id => zombie_id, :data => result.to_json, :date => Time.now.to_i)
    command.save

    # log that the result was returned
    BeEF::Logger.instance.register('Command', "The '#{command_friendly_name}' command module was successfully executed against '#{zombie_ip}'", zombie_id)
  
  end
  
end

end
end