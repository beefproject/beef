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
module Extension
module AdminUI
  
  extend BeEF::API::Extension
  
  @full_name = 'administration web UI'
  
  @short_name = 'admin_ui'
  
  @description = 'command control panel for beef using a web interface'
  
end
end
end

# Constants for that extension
require 'extensions/admin_ui/constants/agents'
require 'extensions/admin_ui/constants/icons'

# Classes
require 'extensions/admin_ui/classes/httpcontroller'
require 'extensions/admin_ui/classes/session'

# Handlers
require 'extensions/admin_ui/handlers/ui'

# API Hooking
require 'extensions/admin_ui/api/command'
require 'extensions/admin_ui/api/handler'
