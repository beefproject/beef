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
  module Hook 
    
    #
    # This method is being called as the hooked response is being built 
    #
    #  Example:
    #
    #     module A
    #       extend BeEF::API::Server::Hook
    #       
    #       def pre_hook_send()
    #         ...
    #       end
    #     end
    #
    def pre_hook_send(handler)

    end
    
  end
  
end
end
end
