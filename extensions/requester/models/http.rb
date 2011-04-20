module BeEF
module Core
module Models
  #
  # Table stores the http requests and responses from the requester.
  #
  class Http
  
    include DataMapper::Resource
    
    storage_names[:default] = 'extension.requester.http'
    
    property :id, Serial

    #
    # The hooked browser id
    #
    property :hooked_browser_id, Text, :lazy => false 

    #
    # The http request to perform. In clear text.
    #
    property :request, Text, :lazy => true
    
    #
    # The http response received. In clear text.
    #
    property :response, Text, :lazy => true
    
    #
    # The http response method. GET or POST.
    #
    property :method, Text, :lazy => false
    
    #
    # The content length for the request.
    #
    property :content_length, Text, :lazy => false, :default => 0
    
    #
    # The domain on which perform the request.
    #
    property :domain, Text, :lazy => false
    
    #
    # The path of the request.
    #
    # Example: /secret.html
    #
    property :path, Text, :lazy => false
    
    #
    # The date at which the http request has been saved.
    #
    property :date, DateTime, :lazy => false
    
    #
    # Boolean value to say if the http response has been received or not.
    #
    property :has_ran, Boolean, :default => false
    
  end
  
end
end
end
