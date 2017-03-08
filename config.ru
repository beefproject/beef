require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'cgi'
require 'yaml'
require 'singleton'
require 'ipaddr'
require 'base64'
require 'xmlrpc/client'
require 'openssl'
require 'rubydns'
require 'mime/types'
require 'optparse'
require 'zip'
require 'rack'

require './core/filters/base'
require './core/filters/browser'
require './core/filters/command'
require './core/filters/page'
require './core/filters/http'
require './core/ruby/security'
require './core/ruby/module'
require './core/ruby/object'
require './core/ruby/string'
require './core/ruby/print'
require './core/ruby/hash'
require './core/ruby/patches/dm-do-adapter/adapter.rb'
require './core/api/module'
require './core/api/modules'
require './core/api/extension'
require './core/api/extensions'
require './core/api/main/migration'
require './core/api/main/network_stack/assethandler.rb'
require './core/api/main/server'
require './core/api/main/server/hook'
require './core/api/main/configuration'
require './core/settings'
require './core/main/models/user'
require './core/main/models/commandmodule'
require './core/main/models/hookedbrowser'
require './core/main/models/log'
require './core/main/models/command'
require './core/main/models/result'
require './core/main/models/optioncache'
require './core/main/models/browserdetails'
require './core/main/constants/browsers'
require './core/main/constants/commandmodule'
require './core/main/constants/distributedengine'
require './core/main/constants/os'
require './core/main/constants/hardware'
require './core/main/configuration'
require './core/main/command'
require './core/main/crypto'
require './core/main/logger'
require './core/main/migration'
require './core/main/console/banners'
require './core/main/router/router'
require './core/main/handlers/internal_mounts'
require './core/main/handlers/modules/beefjs'
require './core/main/handlers/modules/command'
require './core/main/handlers/commands'
require './core/main/handlers/events'
require './core/main/handlers/dyncommands'
require './core/main/handlers/hookedbrowsers'
require './core/main/handlers/browserdetails'
require './core/main/network_stack/handlers/dynamicreconstruction'
require './core/main/network_stack/handlers/redirector'
require './core/main/network_stack/handlers/raw'
require './core/main/network_stack/assethandler'
require './core/main/distributed_engine/models/rules'
require './core/main/autorun_engine/models/rule'
require './core/main/autorun_engine/models/execution'
require './core/main/autorun_engine/parser'
require './core/main/autorun_engine/engine'
require './core/main/autorun_engine/rule_loader'
require './core/module'
require './core/modules'
require './core/extension'
require './core/extensions'
require './core/hbmanager'
require './core/main/rest/handlers/admin_ui'
require './core/main/rest/handlers/hookedbrowsers'
require './core/main/rest/handlers/modules'
require './core/main/rest/handlers/categories'
require './core/main/rest/handlers/logs'
require './core/main/rest/handlers/admin'
require './core/main/rest/handlers/server'
require './core/main/rest/handlers/autorun_engine'
require './core/main/rest/api'

# TODO re-enable WebSockets channel when ready
#require './core/main/network_stack/websocket/websocket'

# AMAZON DEPLOY VIA ELASTIC BEAN STALK.
#  - Make sure there is no Gemfile.lock
#  - set env vars via: eb setenv LANG=en_US.UTF-8
#  - confirm vars are set ok with:
# eb printenv
# Environment Variables:
# LANG = en_US.UTF-8
# LANGUAGE = en_US.UTF-8
# RAILS_SKIP_ASSET_COMPILATION = false
# BUNDLE_WITHOUT = test:development
# RACK_ENV = production
# LC_ALL = en_US.UTF-8
# RAILS_SKIP_MIGRATIONS = false


# If you run locally with rackup, add the following line at the start of this file:
#\ -s puma -w -p 3000

# alternative app servers:
#  Thin --> -s thin -w -p 3000
#  Unicorn, just type (without rackup) ->  unicorn -p 3000


BeEF::Core::Console::Banners.print_welcome_msg
Socket.do_not_reverse_lookup = true

config = BeEF::Core::Configuration.instance
case config.get("beef.database.driver")
  when "sqlite"
    DataMapper.setup(:default, "sqlite3://#{File.expand_path('..', __FILE__)}/#{config.get("beef.database.db_file")}")
  when "mysql", "postgres"
    DataMapper.setup(:default,
                     :adapter => config.get("beef.database.driver"),
                     :host => config.get("beef.database.db_host"),
                     :port => config.get("beef.database.db_port"),
                     :username => config.get("beef.database.db_user"),
                     :password => config.get("beef.database.db_passwd"),
                     :database => config.get("beef.database.db_name"),
                     :encoding => config.get("beef.database.db_encoding")
    )
  else
    print_error 'No default database selected. Please add one in config.yaml'
end
BeEF::Modules.load

DataMapper.auto_migrate!
BeEF::Core::Migration.instance.update_db!

BeEF::Extensions.load

BeEF::Core::Console::Banners.print_loaded_extensions
BeEF::Core::Console::Banners.print_loaded_modules
BeEF::Core::Console::Banners.print_network_interfaces_count
BeEF::Core::Console::Banners.print_network_interfaces_routes
print_info "RESTful API key: #{BeEF::Core::Crypto::api_token}"

BeEF::Core::AutorunEngine::RuleLoader.instance.load_directory


# Core
use BeEF::Core::Handlers::HookedBrowsers
use BeEF::Core::NetworkStack::Handlers::DynamicReconstruction

# RESTful API
use BeEF::Core::Rest::HookedBrowsers
use BeEF::Core::Rest::Modules
use BeEF::Core::Rest::Categories
use BeEF::Core::Rest::Logs
use BeEF::Core::Rest::Admin
use BeEF::Core::Rest::Server # TODO change the way dynamic mounts are added
use BeEF::Core::Rest::AutorunEngine

# Internal Handlers singleton Core
run BeEF::Core::Handlers::Dyncommands
run BeEF::Core::Handlers::BrowserDetails

# new Admin UI Sinatra handlers
#use Rack::Static, :urls => ["/ui/media"], :root => "extensions/admin_ui/media"
# use BeEF::Core::Rest::AdminUi
# use BeEF::Extension::AdminUI::Controllers::Authenticationng
# use BeEF::Extension::AdminUI::Controllers::Panel
# use BeEF::Extension::AdminUI::Controllers::Modules
# use BeEF::Extension::AdminUI::Controllers::Logs

