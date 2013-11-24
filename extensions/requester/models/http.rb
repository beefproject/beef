#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Table stores the http requests and responses from the requester.
  #
  class Http
  
    include DataMapper::Resource
    
    storage_names[:default] = 'extension_requester_http'
    
    property :id, Serial

    # The hooked browser id
    property :hooked_browser_id, Text, :lazy => false

    # The http request to perform. In clear text.
    property :request, Text, :lazy => true

    # Boolean value as string to say whether cross-domain requests are allowed
    property :allow_cross_domain, Text, :lazy => false, :default => "true"

    # The http response body received. In clear text.
    property :response_data, Binary, :lazy => true, :length => 2097152

    # The http response code. Useful to handle cases like 404, 500, 302, ...
    property :response_status_code, Integer, :lazy => true

    # The http response code. Human-readable code: success, error, ecc..
    property :response_status_text, Text, :lazy => true

   # The port status. closed, open or not http
    property :response_port_status, Text, :lazy => true

    # The XHR Http response raw headers
    property :response_headers, Text, :lazy => true

    # The http response method. GET or POST.
    property :method, Text, :lazy => false

    # The content length for the request.
    property :content_length, Text, :lazy => false, :default => 0

    # The domain on which perform the request.
    property :domain, Text, :lazy => false

    # The port on which perform the request.
    property :port, Text, :lazy => false

    # Boolean value to say if the request was cross-domain
    property :has_ran, Text, :lazy => false, :default => "waiting"

    # The path of the request.
    # Example: /secret.html
    property :path, Text, :lazy => false

    # The date at which the http response has been saved.
    property :response_date, DateTime, :lazy => false

    # The date at which the http request has been saved.
    property :request_date, DateTime, :lazy => false

  end
  
end
end
end
