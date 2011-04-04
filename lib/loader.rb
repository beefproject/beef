require 'rubygems'
require 'webrick'
require 'webrick/httpproxy'
require 'dm-core'
require 'dm-migrations'
require 'json'
require 'ansi'
require 'optparse'
require 'cgi'
require 'parseconfig'
require 'singleton'
require 'ipaddr'
require 'base64'
require 'xmlrpc/client'
require 'erubis'

require 'lib/patches/webrick/httprequest'
require 'lib/patches/webrick/cookie'
require 'lib/patches/webrick/genericserver'
require 'lib/patches/webrick/httpresponse'
require 'lib/patches/webrick/httpservlet/filehandler.rb'

require 'lib/constants'
require 'lib/filter/base.rb'
require 'lib/filter/command.rb'
require 'lib/filter/requester.rb'
require 'lib/filter/init.rb'

require 'lib/model/user'
require 'lib/model/commandmodule'
require 'lib/model/zombie'
require 'lib/model/log'
require 'lib/model/command'
require 'lib/model/result'
require 'lib/model/autoloading'
require 'lib/model/plugin'
require 'lib/model/http'
require 'lib/model/browserdetails'
require 'lib/model/distributedenginerules'
require 'lib/model/dynamiccommandinfo'
require 'lib/model/dynamicpayloadinfo.rb'
require 'lib/model/dynamicpayloads.rb'


require 'lib/crypto'

require 'lib/configuration'

require 'lib/console/banner'
require 'lib/console/commandline'
require 'lib/migration'

require 'lib/server/modules/common'
require 'lib/server/modules/requester'

require 'lib/server/httphandler'
require 'lib/server/httpcontroller'

require 'lib/server/httphookserver'
require 'lib/httpproxybase'   
require 'lib/httpproxyzombie'   
require 'lib/httpproxyzombiehandler'

require 'lib/server/assethandler'
require 'lib/server/filehandler'
require 'lib/server/zombiehandler'
require 'lib/server/commandhandler'
require 'lib/server/publichandler'
require 'lib/server/requesterhandler'
require 'lib/server/inithandler'
require 'lib/server/eventhandler'
require 'lib/server/dynamichandler'

require 'lib/logger'
require 'lib/modules/command'

require 'lib/modules/msfclient'
require 'lib/modules/msfcommand'

require 'openssl'

# load command modules
Dir["#{$root_dir}/modules/commands/**/*.rb"].each do |command|
  require command
end
