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
module Extension
module AdminUI
module API
  
  #
  # We use this module to register all the http handler for the Administrator UI
  #
  module Handler
    
    BeEF::API::Registrar.instance.register(BeEF::Extension::AdminUI::API::Handler, BeEF::API::Server, 'mount_handler')
    
    #
    # This function gets called automatically by the server.
    #
    def self.mount_handler(beef_server)
      # retrieve the configuration class instance
      configuration = BeEF::Core::Configuration.instance
      
      # registers the http controllers used by BeEF core (authentication, logs, modules and panel)
      Dir["#{$root_dir}/extensions/admin_ui/controllers/**/*.rb"].each do |http_module|
        require http_module
        mod_name = File.basename http_module, '.rb'
        beef_server.mount("/ui/#{mod_name}", BeEF::Extension::AdminUI::Handlers::UI.new(mod_name))
      end

      # registers the http controllers used by BeEF extensions (requester, proxy, xssrays, etc..)
      Dir["#{$root_dir}/extensions/**/controllers/*.rb"].each do |http_module|
        require http_module
        mod_name = File.basename http_module, '.rb'
        beef_server.mount("/ui/#{mod_name}", BeEF::Extension::AdminUI::Handlers::UI.new(mod_name))
      end
      
      # mount the folder were we store static files (javascript, css, images) for the admin ui
      media_dir = File.dirname(__FILE__)+'/../media/'
      beef_server.mount('/ui/media', Rack::File.new(media_dir))

      
      # mount the favicon file, if we're not imitating a web server.
      if !configuration.get("beef.http.web_server_imitation.enable")
        beef_server.mount('/favicon.ico', Rack::File.new("#{media_dir}#{configuration.get("beef.extension.admin_ui.favicon_dir")}/#{configuration.get("beef.extension.admin_ui.favicon_file_name")}"))
      end
    end
    
  end
  
end
end
end
end
