#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../../../support/constants'
require_relative '../../../../support/beef_test'

RSpec.describe 'AutoRunEngine test' do

	before(:all) do
		@config = BeEF::Core::Configuration.instance
		@config.set('beef.credentials.user', "beef")
		@config.set('beef.credentials.passwd', "beef")
		@username = @config.get('beef.credentials.user')
		@password = @config.get('beef.credentials.passwd')
		
		# Load BeEF extensions and modules
		# Always load Extensions, as previous changes to the config from other tests may affect
		# whether or not this test passes.
		BeEF::Extensions.load
		sleep 2

		# Check if modules already loaded. No need to reload.
		if @config.get('beef.module').nil?
			print_info "Loading in BeEF::Modules"
			BeEF::Modules.load

			sleep 2
		else
				print_info "Modules already loaded"
		end

		# Grab DB file and regenerate if requested
		print_info "Loading database"
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

		sleep 2

		BeEF::Core::Migration.instance.update_db!

		# add AutoRunEngine rule
		test_rule =  {"name"=>"Display an alert", "author"=>"mgeeky", "browser"=>"ALL", "browser_version"=>"ALL", "os"=>"ALL", "os_version"=>"ALL", "modules"=>[{"name"=>"alert_dialog", "condition"=>nil, "options"=>{"text"=>"You've been BeEFed ;>"}}], "execution_order"=>[0], "execution_delay"=>[0], "chain_mode"=>"sequential"}

		BeEF::Core::AutorunEngine::RuleLoader.instance.load_directory
		# are_engine.R

		# Spawn HTTP Server
		print_info "Starting HTTP Hook Server"
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
	end
  
	after(:all) do
		print_info "Shutting down server"
		Process.kill("KILL",@pid)
		Process.kill("KILL",@pids)
 	end

	it 'AutoRunEngine is working' do
		print_info 'Hooking a new victim, waiting a few seconds...'
		victim = BeefTest.new_victim

    sleep 3

		response = RestClient.get "#{RESTAPI_HOOKS}?token=#{@token}"
		result_data = JSON.parse(response)

    expect(result_data['hooked-browsers']['online']).not_to be_empty
	end
 
end
