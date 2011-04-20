module BeEF
module Extension
module Initialization
  
  extend BeEF::API::Extension
  
  @short_name = @full_name = 'initialization'
  
  @description = 'retrieves information about the browser (type, version, plugins etc.)'
  
end
end
end

require 'extensions/initialization/models/browserdetails'
require 'extensions/initialization/handler'
require 'extensions/initialization/api'
