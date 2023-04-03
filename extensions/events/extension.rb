#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Events
      extend BeEF::API::Extension

      @short_name = 'events_logger'
      @full_name = 'Event Logger'
      @description = 'Logs browser events, such as mouse clicks, keystrokes, and form submissions.'
    end
  end
end

require 'extensions/events/handler'
require 'extensions/events/api'
