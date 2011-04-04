$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))

$root_dir = File.expand_path('..', __FILE__)

require 'lib/loader'

# load config
config = BeEF::Configuration.instance

# disable reverse dns
Socket.do_not_reverse_lookup = true 

# setup database
DataMapper.setup(:default, "sqlite3://#{$root_dir}/#{config.get("database_file_name")}")

options = BeEF::Console::CommandLine.parse

if options[:resetdb] 
  DataMapper.auto_migrate!
  BeEF::Migration.instance.update_db!
else 
  DataMapper.auto_upgrade!
end

# check for new command modules
BeEF::Migration.instance.update_db!
  
BeEF::Console::Banner.generate

# start the http proxy if enabled in config.ini
if (config.get('http_proxy_enable').to_i > 0)
  http_proxy_zombie = BeEF::HttpProxyZombie.instance
  http_proxy_zombie.start
end

# start the hook server
http_hook_server = BeEF::HttpHookServer.instance
http_hook_server.start
