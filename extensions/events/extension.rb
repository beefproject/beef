#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Events
  
  extend BeEF::API::Extension
  
  @short_name = 'events_logger'
  
  @full_name = 'events logger'
  
  @description = 'registers mouse clicks, keystrokes, form submissions'
  
end
end
end

require 'extensions/events/handler'
require 'extensions/events/api'
