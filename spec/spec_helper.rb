require 'core/loader.rb'

# Notes
# We need to load vairables that 'beef' usually does for us
## config
config = BeEF::Core::Configuration.new('config.yaml')
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
require 'capybara/cucumber'


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
    if @browser
      @browser.navigate.to('about:blank')
    end
  end
end

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CONFIG_NAME'] || 'browserstack'
CONFIG = YAML.safe_load(File.read("./spec/support/#{CONFIG_NAME}.config.yml"))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || CONFIG['user']
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || CONFIG['key']

## DB config
ActiveRecord::Base.logger = nil
OTR::ActiveRecord.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
OTR::ActiveRecord.configure_from_hash!(adapter:'sqlite3', database:':memory:')
ActiveRecord::Schema.verbose = false
context = ActiveRecord::Migration.new.migration_context
if context.needs_migration?
  ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration).migrate
end

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
  # BrowserStack
  config.around(:example, :run_on_browserstack => true) do |example|
    Capybara.register_driver :browserstack do |app|
      @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])

      # Code to start browserstack local before start of test
      if @caps['browserstack.local'] && @caps['browserstack.local'].to_s == 'true';
        @bs_local = BrowserStack::Local.new
        bs_local_args = {"key" => "#{CONFIG['key']}"}
        @bs_local.start(bs_local_args)
      end

      Capybara::Selenium::Driver.new(app,
        :browser => :remote,
        :url => "http://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
        :desired_capabilities => @caps
      )
    end

    Capybara.default_driver = :browserstack

    # Code to stop browserstack local after end of test
    at_exit do
      @bs_local.stop unless @bs_local.nil? 
    end
  end
end
