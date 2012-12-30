#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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


