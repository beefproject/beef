#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core

  end
end

## @note Include the BeEF router
require 'core/main/router/router'
require 'core/main/router/api'


## @note Include http server functions for beef
require 'core/main/server'
require 'core/main/handlers/modules/beefjs'
require 'core/main/handlers/modules/command'
require 'core/main/handlers/commands'
require 'core/main/handlers/hookedbrowsers'
require 'core/main/handlers/browserdetails'

# @note Include the network stack
require 'core/main/network_stack/handlers/dynamicreconstruction'
require 'core/main/network_stack/handlers/redirector'
require 'core/main/network_stack/handlers/raw'
require 'core/main/network_stack/assethandler'
require 'core/main/network_stack/api'

# @note Include the distributed engine
require 'core/main/distributed_engine/models/rules'

## @note Include helpers
require 'core/module'
require 'core/modules'
require 'core/extension'
require 'core/extensions'
require 'core/hbmanager'

## @note Include RESTful API
require 'core/main/rest/handlers/hookedbrowsers'
require 'core/main/rest/handlers/modules'
require 'core/main/rest/handlers/categories'
require 'core/main/rest/handlers/logs'
require 'core/main/rest/handlers/admin'
require 'core/main/rest/api'

## @note Include Websocket
require 'core/main/network_stack/websocket/websocket'
