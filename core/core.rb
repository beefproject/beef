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

# @note Includes database models - the order must be consistent otherwise DataMapper goes crazy
require 'core/main/models/user'
require 'core/main/models/commandmodule'
require 'core/main/models/hookedbrowser'
require 'core/main/models/log'
require 'core/main/models/command'
require 'core/main/models/result'
require 'core/main/models/optioncache'
require 'core/main/models/browserdetails'

# @note Include the constants
require 'core/main/constants/browsers'
require 'core/main/constants/commandmodule'
require 'core/main/constants/distributedengine'
require 'core/main/constants/os'
require 'core/main/constants/hardware'

# @note Include core modules for beef
require 'core/main/configuration'
require 'core/main/command'
require 'core/main/crypto'
require 'core/main/logger'
require 'core/main/migration'

# @note Include the command line parser and the banner printer
require 'core/main/console/commandline'
require 'core/main/console/banners'


