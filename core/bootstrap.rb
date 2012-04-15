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

# @note Include the network stack
require 'core/main/network_stack/handlers/dynamicreconstruction'
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
require 'core/main/rest/handlers/logs'
require 'core/main/rest/handlers/admin'
require 'core/main/rest/api'
