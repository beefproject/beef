module BeEF
module Extension
module AdminUI
module API
  
  #
  # We use this module to register all the http handler for the Administrator UI
  #
  module Handler
    
    # use of the API right here
    extend BeEF::API::Server::Handler
    
    #
    # This function gets called automatically by the server.
    #
    def self.mount_handlers(beef_server)
      # retrieve the configuration class instance
      configuration = BeEF::Core::Configuration.instance
      
      # registers the http controllers for the AdminUI extensions
      Dir["#{$root_dir}/extensions/admin_ui/controllers/**/*.rb"].each { |http_module|
        require http_module
        mod_name = File.basename http_module, '.rb'
        beef_server.mount("/ui/#{mod_name}", true, BeEF::Extension::AdminUI::Handlers::UI, mod_name)
      }
      
      # mount the folder were we store static files (javascript, css, images) for the admin ui
      media_dir = File.dirname(__FILE__)+'/../media/'
      beef_server.mount('/ui/media', true, BeEF::Extension::AdminUI::Handlers::MediaHandler, media_dir)
      
      # mount the favicon file
      beef_server.mount('/favicon.ico', true, WEBrick::HTTPServlet::FileHandler, "#{media_dir}#{configuration.get("beef.ui.favicon_dir")}/#{configuration.get("beef.ui.favicon_file_name")}")
    end
    
  end
  
end
end
end
end
