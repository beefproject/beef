module BeEF
module Extension
module Demos
  
  extend BeEF::API::Extension
  
  @short_name = 'demos'
  
  @full_name = 'demonstrations'
  
  @description = 'list of demonstration pages for beef'
  
end
end
end

require 'extensions/demos/api'
