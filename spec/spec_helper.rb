require 'core/loader.rb'

# bNotes
# We need to load vairables that 'beef' usually does for us
## config
test_config = ENV['test_config'] || 'config.yaml'
config = BeEF::Core::Configuration.new(test_config)
## home_dir
$home_dir = Dir.pwd
## root_dir
$root_dir = Dir.pwd

require 'core/bootstrap.rb'
require 'rack/test'
require 'curb'
require 'rest-client'
require 'yaml'
require 'selenium-webdriver'
require 'browserstack/local'
require 'byebug'

# Require supports
Dir['spec/support/*.rb'].each do |f|
  require f
end

ENV['RACK_ENV'] ||= 'test'
ARGV = []

## BrowserStack config

## Monkey patch to avoid reset sessions
#class Capybara::Selenium::Driver < Capybara::Driver::Base
#  def reset!
#    if @browser
#      @browser.navigate.to('about:blank')
#    end
#  end
#end
#
#TASK_ID = (ENV['TASK_ID'] || 0).to_i
#CONFIG_FILE = ENV['CONFIG_FILE'] || 'windows/win10/win10_chrome_81.config.yml'

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CONFIG_NAME'] || 'local'
CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), "support/browserstack/config/#{CONFIG_NAME}.config.yml")))
#CONFIG = YAML.safe_load(File.read("./spec/support/browserstack/#{CONFIG_FILE}"))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || ''
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || ''
CONFIG['beef_user'] = ENV['TEST_BEEF_USER']
CONFIG['beef_pass'] = ENV['TEST_BEEF_PASS']
#
### DB config
ActiveRecord::Base.logger = nil
OTR::ActiveRecord.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
OTR::ActiveRecord.configure_from_hash!(adapter:'sqlite3', database: config.get('beef.database.file'))
# otr-activerecord require you to manually establish the connection with the following line
#Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
  OTR::ActiveRecord.establish_connection!
end
ActiveRecord::Schema.verbose = false
#context = ActiveRecord::Migration.new.migration_context
#if context.needs_migration?
#  ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration).migrate
#end

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.bisect_runner = :shell
  config.order = :random
  config.filter_gems_from_backtrace 'rack', 'rack-test', 'activerecord', 'sinatra', 'rspec-core'
  Kernel.srand config.seed
  config.include Rack::Test::Methods
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
#  config.around do |example|
#    ActiveRecord::Base.transaction do
#      example.run
#      raise ActiveRecord::Rollback
#    end
#  end

  def server_teardown(webdriver, server_pid, server_pids)
    begin
      webdriver.quit
    rescue => exception
      print_info "Exception: #{exception}"
      print_info "Exception Class: #{exception.class}"
      print_info "Exception Message: #{exception.message}"
      print_info "Exception Stack Trace: #{exception.backtrace}"
      exit 0
    ensure
      print_info "Shutting down server"
      Process.kill("KILL", server_pid)
      Process.kill("KILL", server_pids)
    end
  end
end
