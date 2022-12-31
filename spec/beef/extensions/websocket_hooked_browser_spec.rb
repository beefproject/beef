#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../spec_helper'
require_relative '../../support/constants'
require_relative '../../support/beef_test'
require 'core/main/network_stack/websocket/websocket'
require 'websocket-client-simple'

RSpec.describe 'Browser hooking with Websockets', run_on_browserstack: true do
  before(:all) do
    @config = BeEF::Core::Configuration.instance
    # Grab DB file and regenerate if requested
    print_info 'Loading database'
    db_file = @config.get('beef.database.file')
    print_info 'Resetting the database for BeEF.'
    File.delete(db_file) if File.exist?(db_file)
    @config.set('beef.credentials.user', 'beef')
    @config.set('beef.credentials.passwd', 'beef')
    @config.set('beef.http.websocket.secure', false)
    @config.set('beef.http.websocket.enable', true)
    @ws = BeEF::Core::Websocket::Websocket.instance
    @username = @config.get('beef.credentials.user')
    @password = @config.get('beef.credentials.passwd')
    # Load BeEF extensions and modules
    # Always load Extensions, as previous changes to the config from other tests may affect
    # whether or not this test passes.
    print_info 'Loading in BeEF::Extensions'
    BeEF::Extensions.load

    # Check if modules already loaded. No need to reload.
    if @config.get('beef.module').nil?
      print_info 'Loading in BeEF::Modules'
      BeEF::Modules.load
    else
      print_info 'Modules already loaded'
    end
    # Load up DB and migrate if necessary
    ActiveRecord::Base.logger = nil
    OTR::ActiveRecord.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
    OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: db_file)
    # otr-activerecord require you to manually establish the connection with the following line
    #Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
    if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
      OTR::ActiveRecord.establish_connection!
    end
    context = ActiveRecord::Migration.new.migration_context
    ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration).migrate if context.needs_migration?
    BeEF::Core::Migration.instance.update_db!
    # Spawn HTTP Server
    print_info 'Starting HTTP Hook Server'
    http_hook_server = BeEF::Core::Server.instance
    http_hook_server.prepare
    # Generate a token for the server to respond with
    @token = BeEF::Core::Crypto.api_token
    # Initiate server start-up
    @pids = fork do
      BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
    end
    @pid = fork do
      http_hook_server.start
    end

    begin
      @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])
      @caps['name'] = self.class.description || ENV['name'] || 'no-name'
      @caps['browserstack.local'] = true
      @caps['browserstack.localIdentifier'] = ENV['BROWSERSTACK_LOCAL_IDENTIFIER']

      @driver = Selenium::WebDriver.for(:remote,
                                        url: "http://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
                                        desired_capabilities: @caps)
      # Hook new victim
      print_info 'Hooking a new victim, waiting a few seconds...'
      wait = Selenium::WebDriver::Wait.new(timeout: 30) # seconds

      @driver.navigate.to VICTIM_URL.to_s

      sleep 3

      sleep 1 until wait.until { @driver.execute_script('return window.beef.session.get_hook_session_id().length') > 0 }

      @session = @driver.execute_script('return window.beef.session.get_hook_session_id().length')
    rescue StandardError => e
      print_info "Exception: #{e}"
      print_info "Exception Class: #{e.class}"
      print_info "Exception Message: #{e.message}"
      print_info "Exception Stack Trace: #{e.backtrace}"
      if @driver.execute_script('return window.beef.session.get_hook_session_id().length').nil?
        exit 1
      else
        exit 0
      end
    end
  end

  after(:all) do
    server_teardown(@driver, @pid, @pids)
  end

  it 'confirms a websocket server has been started' do
    expect(@ws).to be_a_kind_of(BeEF::Core::Websocket::Websocket)
  end

  it 'confirms a secure websocket server has been started' do
    @config.set('beef.http.websocket.secure', true)
    wss = BeEF::Core::Websocket::Websocket.instance
    expect(wss).to be_a_kind_of(BeEF::Core::Websocket::Websocket)
  end

  it 'can successfully hook a browser' do
    expect(@session).not_to be_nil
  rescue StandardError => e
    print_info "Exception: #{e}"
    print_info "Exception Class: #{e.class}"
    print_info "Exception Message: #{e.message}"
    print_info "Exception Stack Trace: #{e.stacktrace}"
    if @driver.execute_script('return window.beef.session.get_hook_session_id().length').nil?
      exit 1
    else
      expect(BeEF::Filters.is_valid_hook_session_id?(@driver.execute_script('return window.beef.session.get_hook_session_id()'))).to eq true
    end
  end
end
