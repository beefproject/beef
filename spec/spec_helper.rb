#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Set external and internal character encodings to UTF-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

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

ENV['RACK_ENV'] ||= 'test' # Set the environment to test
ARGV.clear

## BrowserStack config

# Monkey patch to avoid reset sessions
class Capybara::Selenium::Driver < Capybara::Driver::Base
  def reset!
    @browser.navigate.to('about:blank') if @browser
  end
end

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_FILE = ENV['CONFIG_FILE'] || 'windows/win10/win10_chrome_81.config.yml'
CONFIG = YAML.safe_load(File.read("./spec/support/browserstack/#{CONFIG_FILE}"))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || ''
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || ''

## DB config
ActiveRecord::Base.logger = nil
OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: ':memory:')

# otr-activerecord requires manually establishing the connection with the following line
# Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
  OTR::ActiveRecord.establish_connection!
end
ActiveRecord::Schema.verbose = false

# Migrate (if required)
ActiveRecord::Migration.verbose = false # silence activerecord migration stdout messages
ActiveRecord::Migrator.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
if context.needs_migration?
  ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration, context.internal_metadata).migrate
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
      # byebug
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

########################################

def reset_beef_db
  begin
      db_file = BeEF::Core::Configuration.instance.get('beef.database.file')
      File.delete(db_file) if File.exist?(db_file)
  rescue => e
      print_error("Could not remove '#{db_file}' database file: #{e.message}")
  end
end

require 'socket'

  def port_available?
    socket = TCPSocket.new(@host, @port)
    socket.close
    false  # If a connection is made, the port is in use, so it's not available.
  rescue Errno::ECONNREFUSED
    true   # If the connection is refused, the port is not in use, so it's available.
  rescue Errno::EADDRNOTAVAIL
    true   # If the connection is refused, the port is not in use, so it's available.
  end

  def configure_beef
    # Reset or re-initialise the configuration to a default state
    @config = BeEF::Core::Configuration.instance

    @config.set('beef.credentials.user', "beef")
    @config.set('beef.credentials.passwd', "beef")
    @config.set('beef.http.https.enable', false)
  end

  # Load the server
  def load_beef_extensions_and_modules
      # Load BeEF extensions
      BeEF::Extensions.load

      # Load BeEF modules only if they are not already loaded
      BeEF::Modules.load if @config.get('beef.module').nil?
  end

  def start_beef_server
    configure_beef
    @port = @config.get('beef.http.port')
    @host = @config.get('beef.http.host')
    @host = '127.0.0.1'

    unless port_available?
      print_error "Port #{@port} is already in use. Exiting."
      exit
    end
    load_beef_extensions_and_modules
    
    # Grab DB file and regenerate if requested
    db_file = @config.get('beef.database.file')

    if BeEF::Core::Console::CommandLine.parse[:resetdb]
      File.delete(db_file) if File.exist?(db_file)
    end

    # Load up DB and migrate if necessary
    ActiveRecord::Base.logger = nil
    OTR::ActiveRecord.configure_from_hash!(adapter:'sqlite3', database: db_file)
    # otr-activerecord require you to manually establish the connection with the following line
    #Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
    if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
      OTR::ActiveRecord.establish_connection!
    end

    # Migrate (if required)
    ActiveRecord::Migration.verbose = false # silence activerecord migration stdout messages
    ActiveRecord::Migrator.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
    context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
    if context.needs_migration?
      ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration, context.internal_metadata).migrate
    end

    BeEF::Core::Migration.instance.update_db!

    # Spawn HTTP Server
    # print_info "Starting HTTP Hook Server"
    http_hook_server = BeEF::Core::Server.instance
    http_hook_server.prepare

    # Generate a token for the server to respond with
    BeEF::Core::Crypto::api_token

    # Initiate server start-up
    BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
    pid = fork do
      http_hook_server.start
    end

    return pid
  end

  def beef_server_running?(uri_str)
    begin
      uri = URI.parse(uri_str)
      response = Net::HTTP.get_response(uri)
      response.is_a?(Net::HTTPSuccess)
      rescue Errno::ECONNREFUSED
        return false # Connection refused means the server is not running
      rescue StandardError => e
        return false # Any other error means the server is not running
    end
  end

  def wait_for_beef_server_to_start(uri_str, timeout: 5)
    start_time = Time.now # Record the time we started
    until beef_server_running?(uri_str) || (Time.now - start_time) > timeout do
      sleep 0.1 # Wait a bit before checking again
    end
    beef_server_running?(uri_str) # Return the result of the check
  end

  def start_beef_server_and_wait
    puts "Starting BeEF server"
    pid = start_beef_server
    puts "BeEF server started with PID: #{pid}"

    if wait_for_beef_server_to_start('http://localhost:3000', timeout: SERVER_START_TIMEOUT)
      # print_info "Server started successfully."
    else
      print_error "Server failed to start within timeout."
    end

    pid
  end

  def stop_beef_server(pid)
    exit if pid.nil?
    # Shutting down server
    Process.kill("KILL", pid) unless pid.nil?
    Process.wait(pid) unless pid.nil? # Ensure the process has exited and the port is released 
    pid = nil       
  end

end
