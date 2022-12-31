#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module AdminUI
      extend BeEF::API::Extension

      @full_name = 'Administration Web UI'
      @short_name = 'admin_ui'
      @description = 'Command and control web interface'
    end
  end
end

# Constants
require 'extensions/admin_ui/constants/icons'

# Classes
require 'extensions/admin_ui/classes/httpcontroller'
require 'extensions/admin_ui/classes/session'

# Handlers
require 'extensions/admin_ui/handlers/ui'

# API Hooking
require 'extensions/admin_ui/api/handler'
