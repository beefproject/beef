#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

module BeEF
module Core
module Models

  # @note Table stores the commands that have been sent to the Hooked Browsers.
  class Command

    include DataMapper::Resource

    storage_names[:default] = 'commands'

    property :id, Serial
    property :data, Text
    property :creationdate, String, :length => 15, :lazy => false
    property :label, Text, :lazy => false
    property :instructions_sent, Boolean, :default => false

    has n, :results

    # Save results and flag that the command has been run on the hooked browser
    # @param [String] hook_session_id The session_id.
    # @param [String] command_id The command_id.
    # @param [String] command_friendly_name The command friendly name.
    # @param [String] result The result of the command module.
    def self.save_result(hook_session_id, command_id, command_friendly_name, result)
      # @note enforcing arguments types
      command_id = command_id.to_i

      # @note argument type checking
      raise Exception::TypeError, '"hook_session_id" needs to be a string' if not hook_session_id.string?
      raise Exception::TypeError, '"command_id" needs to be an integer' if not command_id.integer?
      raise Exception::TypeError, '"command_friendly_name" needs to be a string' if not command_friendly_name.string?
      raise Exception::TypeError, '"result" needs to be a hash' if not result.hash?

      # @note get the hooked browser structure and id from the database
      hooked_browser = BeEF::Core::Models::HookedBrowser.first(:session => hook_session_id) || nil
      raise Exception::TypeError, "hooked_browser is nil" if hooked_browser.nil?
      raise Exception::TypeError, "hooked_browser.id is nil" if hooked_browser.id.nil?
      hooked_browser_id = hooked_browser.id
      raise Exception::TypeError, "hooked_browser.ip is nil" if hooked_browser.ip.nil?
      hooked_browser_ip = hooked_browser.ip

      # @note get the command module data structure from the database
      command = first(:id => command_id.to_i, :hooked_browser_id => hooked_browser_id) || nil
      raise Exception::TypeError, "command is nil" if command.nil?

      # @note create the entry for the results 
      command.results.new(:hooked_browser_id => hooked_browser_id, :data => result.to_json, :date => Time.now.to_i)
      command.save

      # @note log that the result was returned
      BeEF::Core::Logger.instance.register('Command', "Hooked browser [id:#{hooked_browser.id}, ip:#{hooked_browser.ip}] has executed instructions from command module [id:#{command_id}, name:'#{command_friendly_name}']", hooked_browser_id)

      # @note prints the event into the console
      if BeEF::Settings.console?
        print_info "Hooked browser [id:#{hooked_browser.id}, ip:#{hooked_browser.ip}] has executed instructions from command module [id:#{command_id}, name:'#{command_friendly_name}']"
      end
    end

  end

end
end
end
