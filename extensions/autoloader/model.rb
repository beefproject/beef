#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Core
module Models
  
class Autoloading < ActiveRecord::Base

  attribute :id, :Serial
  attribute :in_use, :Boolean
  
  belongs_to :command
  
end
  
end
end
end