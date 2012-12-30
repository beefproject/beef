#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
