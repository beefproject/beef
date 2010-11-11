$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))

$root_dir = File.expand_path('..', __FILE__)

require 'lib/loader'

# load config
config = BeEF::Configuration.instance

# setup database
DataMapper.setup(:default, "sqlite3://#{$root_dir}/#{config.get("database_file_name")}")

options = BeEF::Console::CommandLine.parse
if options[:resetdb] then DataMapper.auto_migrate!; BeEF::Migration.instance.update_db!; else DataMapper.auto_upgrade!; end

# check for new command modules
BeEF::Migration.instance.update_db!
  
BeEF::Console::Banner.generate

# start the hook server
http_hook_server = BeEF::HttpHookServer.instance
http_hook_server.start
