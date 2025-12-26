#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../../spec_helper'
require_relative '../../../support/constants'
require_relative '../../../support/beef_test'

RSpec.describe 'BeEF Debug Command Modules:', run_on_browserstack: true do
  before(:all) do
    @__ar_config_snapshot = SpecActiveRecordConnection.snapshot
    # Grab config and set creds in variables for ease of access
    @config = BeEF::Core::Configuration.instance
    @pids = []  # ensure defined for teardown consistency
    # Grab DB file and regenerate if requested
    print_info 'Loading database'
    db_file = @config.get('beef.database.file')
    print_info 'Resetting the database for BeEF.'

    if ENV['RESET_DB']
      File.delete(db_file) if File.exist?(db_file)
    end

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

      # Grab Command Module IDs as they can differ from machine to machine
      @debug_mod_ids = JSON.parse(RestClient.get("#{RESTAPI_MODULES}?token=#{@token}"))
      @debug_mod_names_ids = {}
      @debug_mods = @debug_mod_ids.to_a.select do |cmd_mod|
        category = Array(cmd_mod['category'])
        category_string = if category.is_a?(Array)
                            category.join(', ')
                          else
                            category.to_s
                          end
        category_string.include?('Debug')
      end.map do |debug_mod|
        @debug_mod_names_ids[debug_mod['class']] = debug_mod['id']
      end
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
    disconnect_all_active_record!
    SpecActiveRecordConnection.restore!(@__ar_config_snapshot)
  end

  it 'The Test_beef.debug() command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_beef_debug']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               { "msg": 'test' }.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end

  it 'The Return ASCII Characters command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_return_ascii_chars']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               {}.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end

  it 'The Return Image command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_return_image']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               {}.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end

  it 'The Test HTTP Redirect command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_http_redirect']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               {}.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end

  it 'The Test Returning Results/Long String command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_return_long_string']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               { "repeat": 20,
                                 "repeat_string": 'beef' }.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end

  it 'The Test Network Request command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_network_request']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               { "scheme": 'http',
                                 "method": 'GET',
                                 "domain": ATTACK_DOMAIN.to_s,
                                 "port": @config.get('beef.http.port').to_s,
                                 "path": '/hook.js',
                                 "anchor": 'anchor',
                                 "data": 'query=testquerydata',
                                 "timeout": '10',
                                 "dataType": 'script' }.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end

  it 'The Test DNS Tunnel command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_dns_tunnel_client']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               { "domain": 'example.com',
                                 "data": 'Lorem ipsum' }.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end

  it 'The Test CORS Request command module successfully executes' do
    cmd_mod_id = @debug_mod_names_ids['Test_cors_request']
    response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_mod_id}?token=#{@token}",
                               { "method": 'GET',
                                 "url": 'example.com',
                                 "data": {
                                   "test": 'data'
                                 } }.to_json,
                               content_type: :json
    result_data = JSON.parse(response.body)
    expect(result_data['success']).to eq 'true'
  end
end
