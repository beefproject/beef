module BeEF
module API
module Server
  #
  # All modules that extend the Handler API will be called during handler mounting,
  # dismounting, managing operations.
  #
  # You want to use that API if you are developing an extension that requires to create
  # a new http handler to receive responses.
  #
  #  Example:
  #
  #     module A
  #       extend BeEF::API::Server::Handler
  #     end
  #
  #
  # BeEF Core then calls all the Handler extension modules like this:
  #
  #   BeEF::API::Server::Handler.extended_in_modules.each do |mod|
  #     ...
  #   end
  #
  module Handler
    
    API_PATHS = {
        'pre_http_start' => :pre_http_start,
        'mount_handlers' => :mount_handlers
    }
    
    #
    # This method is being called when the BeEF server mounts handlers
    #
    # See BeEF::Extension::AdminUI::API::Handler as an example.
    #
    #  Example:
    #
    #     module A
    #       extend BeEF::API::Server::Handler
    #       
    #       def mount_handlers(beef_server)
    #         ...
    #       end
    #     end
    #
    def mount_handlers(beef_server)
      #
      # Here's an example of how you could use it:
      #
      #   beef_server.mount('/demos/', true, WEBrick::HTTPServlet::FileHandler, "#{$root_dir}/demos/")
      #
    end

    def pre_http_start(http_hook_server)

    end
    
  end
  
end
end
end
