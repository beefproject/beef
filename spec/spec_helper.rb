# frozen_string_literal: true
#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Set external and internal character encodings to UTF-8
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'logger'
require 'net/http'
require 'uri'

require 'core/loader.rb'

# We need to load variables that 'beef' usually does for us
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
Dir['spec/support/*.rb'].each { |f| require f }

ENV['RACK_ENV'] ||= 'test' # Set the environment to test
ARGV.clear

SERVER_START_TIMEOUT = Integer(ENV['SERVER_START_TIMEOUT'] || 20)

## BrowserStack config

# Monkey patch to avoid reset sessions
class Capybara::Selenium::Driver < Capybara::Driver::Base
  def reset!
    @browser.navigate.to('about:blank') if @browser
  end
end

TASK_ID     = (ENV['TASK_ID'] || 0).to_i
CONFIG_FILE = ENV['CONFIG_FILE'] || 'windows/win10/win10_chrome_81.config.yml'
CONFIG      = YAML.safe_load(File.read("./spec/support/browserstack/#{CONFIG_FILE}"))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || ''
CONFIG['key']  = ENV['BROWSERSTACK_ACCESS_KEY'] || ''

## DB config for unit tests (in-memory). We will disconnect these before forking the server.
ActiveRecord::Base.logger = nil
OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: ':memory:')
if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
  OTR::ActiveRecord.establish_connection!
end
ActiveRecord::Schema.verbose = false

# Migrate (if required) for the in-memory schema used by non-server specs
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
mem_context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
if mem_context.needs_migration?
  ActiveRecord::Migrator
    .new(:up, mem_context.migrations, mem_context.schema_migration, mem_context.internal_metadata)
    .migrate
end

# -------------------------------------------------------------------
# Console logger shims
# Some extensions may call Console.level= or BeEF::Core::Console.level=
# Ensure both are safe.
# -------------------------------------------------------------------
module BeEF
  module Core
    module Console
      class << self
        attr_accessor :logger
        def level=(val)
          (self.logger ||= Logger.new($stdout)).level = val
        end
        def level
          (self.logger ||= Logger.new($stdout)).level
        end
        # Proxy common logger methods if called directly (info, warn, error, etc.)
        def method_missing(m, *args, &blk)
          lg = (self.logger ||= Logger.new($stdout))
          return lg.public_send(m, *args, &blk) if lg.respond_to?(m)
          super
        end
        def respond_to_missing?(m, include_priv = false)
          (self.logger ||= Logger.new($stdout)).respond_to?(m, include_priv) || super
        end
      end
    end
  end
end
BeEF::Core::Console.logger ||= Logger.new($stdout)

# Some code may reference a top-level ::Console constant (not namespaced)
unless defined?(::Console) && ::Console.respond_to?(:level=)
  module ::Console
    class << self
      attr_accessor :logger
      def level=(val)
        (self.logger ||= Logger.new($stdout)).level = val
      end
      def level
        (self.logger ||= Logger.new($stdout)).level
      end
      # Proxy to logger for typical logging calls
      def method_missing(m, *args, &blk)
        lg = (self.logger ||= Logger.new($stdout))
        return lg.public_send(m, *args, &blk) if lg.respond_to?(m)
        super
      end
      def respond_to_missing?(m, include_priv = false)
        (self.logger ||= Logger.new($stdout)).respond_to?(m, include_priv) || super
      end
    end
  end
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
    Process.kill('KILL', server_pid) if server_pid
    Array(server_pids).compact.each { |pid| Process.kill('KILL', pid) }
  end

  ########################################

  def reset_beef_db
    db_file = BeEF::Core::Configuration.instance.get('beef.database.file')
    File.delete(db_file) if File.exist?(db_file)
  rescue => e
    print_error("Could not remove '#{db_file}' database file: #{e.message}")
  end

  require 'socket'

  def port_available?
    socket = TCPSocket.new(@host, @port)
    socket.close
    false # If a connection is made, the port is in use.
  rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
    true  # Connection refused/unavailable => port is free.
  end

  def configure_beef
    # Reset or re-initialise the configuration to a default state
    @config = BeEF::Core::Configuration.instance
    @config.set('beef.credentials.user',  'beef')
    @config.set('beef.credentials.passwd','beef')
    @config.set('beef.http.https.enable', false)
  end

  # Load the server
  def load_beef_extensions_and_modules
    # Load BeEF extensions
    BeEF::Extensions.load
    # Load BeEF modules only if they are not already loaded
    BeEF::Modules.load if @config.get('beef.module').nil?
  end

  # --- HARD fork-safety: disconnect every pool/adapter we can find ---
  def disconnect_all_active_record!
    if defined?(ActiveRecord::Base)
      # Disconnect every connection pool explicitly
      handler = ActiveRecord::Base.connection_handler
      handler.connection_pool_list.each { |pool| pool.disconnect! } if handler.respond_to?(:connection_pool_list)
      ActiveRecord::Base.clear_active_connections!
      ActiveRecord::Base.clear_all_connections!
    end
    OTR::ActiveRecord.disconnect! if defined?(OTR::ActiveRecord)
  end

  def start_beef_server
    configure_beef
    @port = @config.get('beef.http.port')
    @host = '127.0.0.1'

    unless port_available?
      print_error "Port #{@port} is already in use. Exiting."
      exit 1
    end
    load_beef_extensions_and_modules

    # DB file for BeEF runtime (not the in-memory test DB)
    db_file = @config.get('beef.database.file')

    if BeEF::Core::Console::CommandLine.parse[:resetdb]
      File.delete(db_file) if File.exist?(db_file)
    end

    # ***** IMPORTANT: close any and all AR/OTR connections before forking *****
    disconnect_all_active_record!

    pid = fork do
      # Child: establish a fresh connection to the file DB
      OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: db_file)
      if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
        OTR::ActiveRecord.establish_connection!
      end

      # Apply migrations for runtime DB
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Migrator.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
      context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
      if context.needs_migration?
        ActiveRecord::Migrator
          .new(:up, context.migrations, context.schema_migration, context.internal_metadata)
          .migrate
      end

      BeEF::Core::Migration.instance.update_db!

      # Spawn HTTP Server
      http_hook_server = BeEF::Core::Server.instance
      http_hook_server.prepare

      # Generate a token for the server to respond with
      BeEF::Core::Crypto::api_token

      # Fire pre_http_start hooks (Dns extension, etc.)
      BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)

      # Start server (blocking call)
      http_hook_server.start
    end

    pid
  end

  def beef_server_running?(uri_str)
    uri = URI.parse(uri_str)
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue Errno::ECONNREFUSED, StandardError
    false
  end

  def wait_for_beef_server_to_start(uri_str, timeout: 5)
    start_time = Time.now
    until beef_server_running?(uri_str) || (Time.now - start_time) > timeout
      sleep 0.1
    end
    beef_server_running?(uri_str)
  end

  def start_beef_server_and_wait
    puts 'Starting BeEF server'
    pid = start_beef_server
    puts "BeEF server started with PID: #{pid}"

    unless wait_for_beef_server_to_start('http://localhost:3000', timeout: SERVER_START_TIMEOUT)
      print_error 'Server failed to start within timeout.'
    end

    pid
  end

  def stop_beef_server(pid)
    return if pid.nil?
    Process.kill('KILL', pid)
    Process.wait(pid)
  end
end