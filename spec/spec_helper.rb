require 'core/loader.rb'

# @note We need to load variables that 'beef' usually does for us

# @todo review this config (this isn't used or is shadowed by the monkey patching, needs a further look to fix properly)
config = BeEF::Core::Configuration.new('config.yaml')
$home_dir = Dir.pwd
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

# Monkey patch to avoid reset sessions
class Capybara::Selenium::Driver < Capybara::Driver::Base
  def reset!
    @browser.navigate.to('about:blank') if @browser
  end
end

TASK_ID = (ENV['TASK_ID'] || 0).to_i
print_info ENV['CONFIG_FILE']
CONFIG_FILE = ENV['CONFIG_FILE'] || 'windows/win10/win10_chrome_81.config.yml'
CONFIG = YAML.safe_load(File.read("./spec/support/browserstack/#{CONFIG_FILE}"))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || ''
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || ''

## DB config
ActiveRecord::Base.logger = nil
OTR::ActiveRecord.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: ':memory:')

# otr-activerecord requires manually establishing the connection with the following line
# Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
  OTR::ActiveRecord.establish_connection!
end
ActiveRecord::Schema.verbose = false
context = ActiveRecord::Migration.new.migration_context
ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration).migrate if context.needs_migration?

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.bisect_runner = :shell
  config.order = :random
  Kernel.srand config.seed
  config.include Rack::Test::Methods
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  def server_teardown(webdriver, server_pid, server_pids)
    webdriver.quit
  rescue StandardError => e
    print_info "Exception: #{e}"
    print_info "Exception Class: #{e.class}"
    print_info "Exception Message: #{e.message}"
    print_info "Exception Stack Trace: #{e.backtrace}"
    exit 0
  ensure
    print_info 'Shutting down server'
    Process.kill('KILL', server_pid)
    Process.kill('KILL', server_pids)
  end
end
