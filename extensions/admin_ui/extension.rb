#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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

r = File.expand_path('../', __FILE__)
require "#{r}/constants/agents.rb"
require "#{r}/constants/icons.rb"

require "#{r}/classes/httpcontroller.rb"
require "#{r}/classes/session.rb"

require "#{r}/api/command.rb"
require "#{r}/api/handler.rb"

require "#{r}/controllers/authentication/authenticationng.rb"
require "#{r}/controllers/logs/logs.rb"
require "#{r}/controllers/modules/modules.rb"
require "#{r}/controllers/panel/panel.rb"


# require "#{r}/handlers/ngui.rb"
