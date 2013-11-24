#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  
class Autoloading
  
  include DataMapper::Resource
  
  storage_names[:default] = 'autoloading'
  
  property :id, Serial
  property :in_use, Boolean
  
  belongs_to :command
  
end
  
end
end
end