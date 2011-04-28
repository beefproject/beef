module BeEF
module Core
module Handlers
module Modules

  module Command

    #
    # Adds the command module instructions to a hooked browser's http response. 
    #
    def add_command_instructions(command, hooked_browser)

      raise WEBrick::HTTPStatus::BadRequest, "hooked_browser is nil" if hooked_browser.nil?
      raise WEBrick::HTTPStatus::BadRequest, "hooked_browser.session is nil" if hooked_browser.session.nil?
      raise WEBrick::HTTPStatus::BadRequest, "hooked_browser is nil" if command.nil?
      raise WEBrick::HTTPStatus::BadRequest, "hooked_browser.command_module_id is nil" if command.command_module_id.nil?

      # get the command module
      command_module = BeEF::Core::Models::CommandModule.first(:id => command.command_module_id)      
      raise WEBrick::HTTPStatus::BadRequest, "command_module is nil" if command_module.nil?
      raise WEBrick::HTTPStatus::BadRequest, "command_module.path is nil" if command_module.path.nil?

      if(command_module.path.match(/^Dynamic/))
         command_module = BeEF::Modules::Commands.const_get(command_module.name.capitalize).new
      else
         command_module = BeEF::Core::Command.const_get(command_module.name.capitalize).new
      end

      command_module.command_id = command.id
      command_module.session_id = hooked_browser.session
      command_module.build_datastore(command.data)
      command_module.pre_send

      build_missing_beefjs_components(command_module.beefjs_components) if not command_module.beefjs_components.empty?

      @body << command_module.output + "\n\n"
      
      # prints the event to the console
      if BeEF::Settings.console?
      name = command_module.friendlyname || kclass
      print_info "Hooked browser #{hooked_browser.ip} has been sent instructions from command module '#{name}'"
      end

      # flag that the command has been sent to the hooked browser
      command.instructions_sent = true 
      command.save
    end

  end

end
end
end
end
