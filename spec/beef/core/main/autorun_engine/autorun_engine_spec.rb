#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../../../spec_helper'
require_relative '../../../../support/constants'
require_relative '../../../../support/beef_test'

RSpec.describe 'AutoRunEngine Test', run_on_browserstack: true do
  before(:all) do
    @__ar_config_snapshot = SpecActiveRecordConnection.snapshot
    @config = BeEF::Core::Configuration.instance

    # Grab DB file and regenerate if requested
    print_info 'Loading database'
    db_file = @config.get('beef.database.file')
    print_info 'Resetting the database for BeEF.'

    if ENV['RESET_DB']
      File.delete(db_file) if File.exist?(db_file)
    end

    @config.set('beef.credentials.user', 'beef')
    @config.set('beef.credentials.passwd', 'beef')
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
    OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: db_file)
    # otr-activerecord require you to manually establish the connection with the following line
    #Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
    if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
      OTR::ActiveRecord.establish_connection!
    end
    ActiveRecord::Migrator.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
    MUTEX.synchronize do
      context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
      if context.needs_migration?
        ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration, context.internal_metadata).migrate
      end
    end
    
    BeEF::Core::Migration.instance.update_db!

    # add AutoRunEngine rule
    test_rule = { 'name' => 'Display an alert', 'author' => 'mgeeky', 'browser' => 'ALL', 'browser_version' => 'ALL', 'os' => 'ALL', 'os_version' => 'ALL', 'modules' => [{ 'name' => 'alert_dialog', 'condition' => nil, 'options' => { 'text' => "You've been BeEFed ;>" } }], 'execution_order' => [0], 'execution_delay' => [0], 'chain_mode' => 'sequential' }

    BeEF::Core::AutorunEngine::RuleLoader.instance.load_directory
    # are_engine.R

    # Spawn HTTP Server
    print_info 'Starting HTTP Hook Server'
    http_hook_server = BeEF::Core::Server.instance

    # Generate a token for the server to respond with
    @token = BeEF::Core::Crypto.api_token

    # ***** IMPORTANT: close any and all AR/OTR connections before forking *****
    disconnect_all_active_record!

    # Initiate server start-up
    @pid = fork do
      http_hook_server.prepare
      BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
      http_hook_server.start
    end

    begin
      @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])
      @caps['name'] = self.class.description || ENV['name'] || 'no-name'
      @caps['browserstack.local'] = true
      @caps['browserstack.localIdentifier'] = ENV['BROWSERSTACK_LOCAL_IDENTIFIER']

      @driver = Selenium::WebDriver.for(:remote,
                                        url: "http://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
                                        options: @caps)
      # Hook new victim
      print_info 'Hooking a new victim, waiting a few seconds...'
      wait = Selenium::WebDriver::Wait.new(timeout: 30) # seconds

      @driver.navigate.to VICTIM_URL.to_s

      sleep 1

      sleep 1 until wait.until { @driver.execute_script('return window.beef.session.get_hook_session_id().length') > 0 }

      @session = @driver.execute_script('return window.beef.session.get_hook_session_id()')
    end
  end

  after(:all) do
    server_teardown(@driver, @pid, @pids)
    disconnect_all_active_record!
    SpecActiveRecordConnection.restore!(@__ar_config_snapshot)
  end

  it 'AutoRunEngine is working' do
    expect(@session).not_to be_nil
  end
end
