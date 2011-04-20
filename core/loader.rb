#
# Include here all the gems we are using
#
require 'rubygems'
require 'webrick'
require 'webrick/httpproxy'
require 'dm-core'
require 'dm-migrations'
require 'json'
require 'ansi'
require 'optparse'
require 'cgi'
require 'yaml'
require 'singleton'
require 'ipaddr'
require 'base64'
require 'xmlrpc/client'
require 'erubis'
require 'openssl'
require 'term/ansicolor'

# Include the filters
require 'core/filters'

# Include our patches for ruby and gems
require 'core/ruby'

# Include the API
require 'core/api'

# Include the settings
require 'core/settings'

# Include the core of BeEF
require 'core/core'

# Include the extensions
require 'core/extensions'

# Include the modules
require 'core/modules'
