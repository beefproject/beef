#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  #
  # Store the rays details, basically verified XSS vulnerabilities
  #
  class Xssraysdetail
  
    include DataMapper::Resource
    
    storage_names[:default] = 'extension_xssrays_details'
    
    property :id, Serial

    # The hooked browser id
    property :hooked_browser_id, Text, :lazy => false

    # The XssRays vector name for the vulnerability
    property :vector_name, Text, :lazy => true

    # The XssRays vector method (GET or POST) for the vulnerability
    property :vector_method, Text, :lazy => true

    # The XssRays Proof of Concept for the vulnerability
    property :vector_poc, Text, :lazy => true

    belongs_to :xssraysscan
  end
  
end
end
end
