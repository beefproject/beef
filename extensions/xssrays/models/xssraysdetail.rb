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
