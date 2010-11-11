module BeEF
module UI

#
#
#
class Modules < BeEF::HttpController
  
  BD = BeEF::Models::BrowserDetails
  
  def initialize
    super({
      'paths' => {
        'select_all_command_modules'      => '/select/commandmodules/all.json',
        'select_command_modules_tree'     => '/select/commandmodules/tree.json',
        'select_command_module'           => '/select/commandmodule.json',
        'select_command'                  => '/select/command.json',
        'select_command_results'          => '/select/command_results.json',
        'select_zombie_summary'           => '/select/zombie_summary.json',
        'select_command_module_commands'  => '/commandmodule/commands.json',
        'attach_command_module'           => '/commandmodule/new',
        'reexecute_command_module'        => '/commandmodule/reexecute'
      }
    })
    
    @session = BeEF::UI::Session.instance
  end
  
  # Returns a JSON array containing the summary for a selected zombie.
  def select_zombie_summary

    # get the zombie 
    zombie_session = @params['zombie_session'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Zombie session is nil" if zombie_session.nil?
    zombie = BeEF::Models::Zombie.first(:session => zombie_session)
    raise WEBrick::HTTPStatus::BadRequest, "Zombie is nil" if zombie.nil?

    # init the summary grid
    summary_grid_hash = {
      'success' => 'true', 
      'results' => []
    }

    # set and add the return values for the browser name
    browser_name = BD.get(zombie_session, 'BrowserName') 
    friendly_browser_name = BeEF::Constants::Browsers.friendly_name(browser_name)
    browser_name_hash = { 'Browser Name' => friendly_browser_name }

    browser_name_row = {
      'category' => 'Browser Hook Initialisation',
      'data' => browser_name_hash,
      'from' => 'Initialisation'
    }
    
    summary_grid_hash['results'].push(browser_name_row) # add the row

    # set and add the return values for the browser version
    browser_version = BD.get(zombie_session, 'BrowserVersion') 
    browser_version_hash = { 'Browser Version' => browser_version }

    browser_version_row = {
      'category' => 'Browser Hook Initialisation',
       'data' => browser_version_hash,
      'from' => 'Initialisation'
    }
    
    summary_grid_hash['results'].push(browser_version_row) # add the row

    @body = summary_grid_hash.to_json
      
  end
      
  # Returns the list of all command_modules in a JSON format
  def select_all_command_modules
    @body = command_modules2json(Dir["#{$root_dir}/modules/commands/**/*.rb"])
  end
  
  # Returns the list of all command_modules for a TreePanel in the interface.
  def select_command_modules_tree
    command_modules_tree_array = []
    command_modules_categories = []
    
    # get an array of all the command modules in the database
    db_command_modules = BeEF::Models::CommandModule.all(:order => [:id.asc])
    raise WEBrick::HTTPStatus::BadRequest, "db_command_modules is nil" if db_command_modules.nil?
    
    db_command_modules.each {|command_module_db_details|

      # get the hooked browser session id and set it in the command module
      hook_session_id = @params['zombie_session'] || nil
      raise WEBrick::HTTPStatus::BadRequest, "hook_session_id is nil" if hook_session_id.nil?

      # create an instance of the comand module
      command_module_name = File.basename command_module_db_details.path, '.rb' # get the name
      command_module = BeEF::Modules::Commands.const_get(command_module_name.capitalize).new
      command_module.session_id = hook_session_id 
      
      # set command module treeview display properties 
      command_module_friendly_name = command_module.info['Name'].downcase
      command_module_category = command_module.info['Category'].downcase
      
      # create url path and file for the command module icon
      command_module_icon_path =  BeEF::Constants::CommandModule::MODULE_TARGET_IMG_PATH # add icon path
      case command_module.verify_target() # select the correct icon for the command module
      when BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_NOT_WORKING
        command_module_icon_path += BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_NOT_WORKING_IMG
      when BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_WORKING
        command_module_icon_path += BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_WORKING_IMG
      when BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_UNKNOWN
        command_module_icon_path += BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_UNKNOWN_IMG
      else
        command_module_icon_path += BeEF::Constants::CommandModule::MODULE_TARGET_VERIFIED_UNKNOWN_IMG
      end
      
      # construct the category branch if it doesn't exist for the command module tree
      if not command_modules_categories.include? command_module_category
        command_modules_categories.push(command_module_category) # flag that the categor has been added
        command_modules_tree_array.push({ # add the branch structure
          'text' => command_module_category,
          'cls' => 'folder',
          'children' => []
        })
      end

      # construct leaf node for the command module tree
      leaf_node = {
          'text' => command_module_friendly_name,
          'leaf' => true,
          'icon' => command_module_icon_path,
          'id' => command_module_db_details.id
      }
        
      # add the node to the branch in the command module tree
      command_modules_tree_array.each {|x|
        if x['text'].eql? command_module_category
          x['children'].push( leaf_node )
            break
        end
      }
    
    }
      
    # sort the array/tree 
    command_modules_tree_array.sort! {|a,b| a['text'] <=> b['text']}
      
    # append the number of command modules so the branch name results in: "<category name> (num)"
    command_modules_tree_array.each {|command_module_branch|
      num_of_command_modules = command_module_branch['children'].length
      command_module_branch['text'] = command_module_branch['text'] + " (" + num_of_command_modules.to_s() + ")"
    }
      
    # return a JSON array of hashes
    @body = command_modules_tree_array.to_json
  end
  
  # Returns the absolute path of the rb file mapped to the id in the database
  def get_command_module_path(command_module_id)

    # get command_module from database
    raise WEBrick::HTTPStatus::BadRequest, "command_module id is nil" if command_module_id.nil?
    command_module = BeEF::Models::CommandModule.first(:id => command_module_id) 
    raise WEBrick::HTTPStatus::BadRequest, "Invalid command_module id" if command_module.nil?

    # construct command_module path
    absolute_command_module_path = $root_dir+File::SEPARATOR+command_module.path
    raise WEBrick::HTTPStatus::BadRequest, "command_module file does not exist" if not File.exists?(absolute_command_module_path)
    
    absolute_command_module_path
  end
  
  
  # Returns the inputs definition of an command_module.
  def select_command_module  
    
    # get command_module id
    command_module_id = @params['command_module_id'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "command_module_id is nil" if command_module_id.nil?

    # get the command_module path
    absolute_command_module_path = get_command_module_path(command_module_id)
    
    @body = command_modules2json([absolute_command_module_path]); 
  end
  
  # Returns the list of commands for an command_module
  def select_command_module_commands
    commands = []
    i=0

    # get params
    zombie_session = @params['zombie_session'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Zombie session is nil" if zombie_session.nil?
    command_module_id = @params['command_module_id'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "command_module id is nil" if command_module_id.nil?
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce
    
    # get the browser id
    zombie = Z.first(:session => zombie_session)
    raise WEBrick::HTTPStatus::BadRequest, "Zombie is nil" if zombie.nil?
    zombie_id = zombie.id
    raise WEBrick::HTTPStatus::BadRequest, "Zombie id is nil" if zombie_id.nil?
      
    C.all(:command_module_id => command_module_id, :zombie_id => zombie_id).each do |command|
      commands.push({
        'id' => i, 
        'object_id' => command.id, 
        'creationdate' => Time.at(command.creationdate.to_i).strftime("%Y-%m-%d %H:%M").to_s, 
        'label' => command.label
        })
      i+=1
    end
      
    @body = {
      'success' => 'true', 
      'commands' => commands}.to_json
      
  end
  
  # Attaches an command_module to a zombie.
  def attach_command_module
    
    definition = {}

    # get params
    zombie_session = @params['zombie_session'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Zombie id is nil" if zombie_session.nil?
    command_module_id = @params['command_module_id'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "command_module id is nil" if command_module_id.nil?
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce
    
    @params.keys.each {|param| 
      raise WEBrick::HTTPStatus::BadRequest, "invalid key param string" if not Filter.has_valid_param_chars?(param)
      raise WEBrick::HTTPStatus::BadRequest, "first char is num" if Filter.first_char_is_num?(param)
      definition[param[4..-1]] = params[param]
    }

    zombie = Z.first(:session => zombie_session)
    raise WEBrick::HTTPStatus::BadRequest, "Zombie is nil" if zombie.nil?
    zombie_id = zombie.id
    raise WEBrick::HTTPStatus::BadRequest, "Zombie id is nil" if zombie_id.nil?
    
    C.new(  :data => definition.to_json,
            :zombie_id => zombie_id,
            :command_module_id => command_module_id,
            :creationdate => Time.new.to_i
          ).save
    
    @body = '{success : true}'
  end
  
  # Re-execute an command_module to a zombie.
  def reexecute_command_module
    
    # get params
    command_id = @params['command_id'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Command id is nil" if command_id.nil?
    command = BeEF::Models::Command.first(:id => command_id.to_i) || nil
    raise WEBrick::HTTPStatus::BadRequest, "Command is nil" if command.nil?
    # validate nonce
    nonce = @params['nonce'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "nonce is nil" if nonce.nil?
    raise WEBrick::HTTPStatus::BadRequest, "nonce incorrect" if @session.get_nonce != nonce
    
    command.has_run = false
    command.save
      
    @body = '{success : true}'
  end
  
  # Returns the results of a command
  def select_command_results
    results = []
    
    # get params
    command_id = @params['command_id'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Command id is nil" if command_id.nil?
    command = BeEF::Models::Command.first(:id => command_id.to_i) || nil
    raise WEBrick::HTTPStatus::BadRequest, "Command is nil" if command.nil?

    # get command_module
    command_module = BeEF::Models::CommandModule.first(:id => command.command_module_id)
    raise WEBrick::HTTPStatus::BadRequest, "command_module is nil" if command_module.nil?
    command_module_name = File.basename command_module.path, '.rb'
    
    resultsdb = BeEF::Models::Result.all(:command_id => command_id)
    raise WEBrick::HTTPStatus::BadRequest, "Command id result is nil" if resultsdb.nil?
    
    resultsdb.each{ |result| results.push({'date' => result.date, 'data' => JSON.parse(result.data)}) }
    
    @body = {
      'success'             => 'true', 
      'command_module_name' => command_module_name,
      'command_module_id'   => command_module.id,
      'results'             => results}.to_json

  end
  
  # Returns the definition of a command.
  # In other words it returns the command that was used to command_module a zombie.
  def select_command
    
    # get params
    command_id = @params['command_id'] || nil
    raise WEBrick::HTTPStatus::BadRequest, "Command id is nil" if command_id.nil?
    command = BeEF::Models::Command.first(:id => command_id.to_i) || nil
    raise WEBrick::HTTPStatus::BadRequest, "Command is nil" if command.nil?
    
    command_module = BeEF::Models::CommandModule.first(:id => command.command_module_id)
    raise WEBrick::HTTPStatus::BadRequest, "command_module is nil" if command_module.nil?
    command_module_name = File.basename command_module.path, '.rb'
      
    e = BeEF::Modules::Commands.const_get(command_module_name.capitalize).new
            
    @body = {
      'success' => 'true', 
      'command_module_name'  => command_module_name,
      'command_module_id'    => command_module.id,
      'data'                 => JSON.parse(command.data),
      'definition'           => JSON.parse(e.to_json)
    }.to_json

  end
  
  private
  
  # Takes a list of command_modules and returns them as a JSON array
  def command_modules2json(command_modules)
    command_modules_json = {}
    i = 1
    
    command_modules.each do |command_module|
      next if not File.exists?(command_module)
      
      e = File.basename command_module, '.rb'
      e = BeEF::Modules::Commands.const_get(e.capitalize).new
      command_modules_json[i] = JSON.parse(e.to_json)
      i += 1
    end
    
    if not command_modules_json.empty?
      return {'success' => 'true', 'command_modules' => command_modules_json}.to_json
    else
      return {'success' => 'false'}.to_json
    end
  end
  
end

end
end
