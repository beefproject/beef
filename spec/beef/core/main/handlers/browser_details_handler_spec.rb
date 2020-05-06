#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../../../support/constants'
require_relative '../../../../support/beef_test'

RSpec.describe 'Browser Details Handler', :run_on_browserstack => true do
	before(:all) do
		@config = BeEF::Core::Configuration.instance
		@config.set('beef.credentials.user', "beef")
		@config.set('beef.credentials.passwd', "beef")
		@username = @config.get('beef.credentials.user')
		@password = @config.get('beef.credentials.passwd')
		
		# Load BeEF extensions and modules
		# Always load Extensions, as previous changes to the config from other tests may affect
		# whether or not this test passes.
		print_info "Loading in BeEF::Extensions"
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

		# Spawn HTTP Server
		print_info "Starting HTTP Hook Server"
		http_hook_server = BeEF::Core::Server.instance
		http_hook_server.prepare

		# Generate a token for the server to respond with
		@token = BeEF::Core::Crypto::api_token

		# Initiate server start-up
		@pids = fork do
			BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
		end
		@pid = fork do
			http_hook_server.start
		end

		# Give the server time to start-up
		sleep 1

		@caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])
		@caps["name"] = self.class.description || ENV['name'] || 'no-name'
		@caps["browserstack.local"] = true
		@caps['browserstack.localIdentifier'] = ENV['BROWSERSTACK_LOCAL_IDENTIFIER']

		@driver = Selenium::WebDriver.for(:remote,
				:url => "http://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
				:desired_capabilities => @caps)

		# Hook new victim
		print_info 'Hooking a new victim, waiting a few seconds...'
		wait = Selenium::WebDriver::Wait.new(:timeout => 30) # seconds

		@driver.navigate.to "#{VICTIM_URL}"

		sleep 3

		# Give time for browser hook to occur
		sleep 1 until wait.until { @driver.execute_script("return window.beef.session.get_hook_session_id().length") > 0}

		begin
			@hooks = JSON.parse(RestClient.get "#{RESTAPI_HOOKS}?token=#{@token}")
			if @hooks['hooked-browsers']['online'].empty?
				puts @hooks['hooked-browsers']['online']
				@session = @hooks['hooked-browsers']['online']['0']['session']
			else
				@session = @driver.execute_script("return window.beef.session.get_hook_session_id()")
			end
		rescue => exception
			print_info "Encountered Exception: #{exception}"
			print_info "Continuing to grab Session ID from client"
			@session = @driver.execute_script("return window.beef.session.get_hook_session_id()")
		end
	end

	after(:all) do
		@driver.quit

		print_info "Shutting down server"
		Process.kill("KILL",@pid)
		Process.kill("KILL",@pids)
	end

	it 'can successfully hook a browser' do
		if @hooks['hooked-browsers']['online'].empty?
			expect(BeEF::Filters.is_valid_hook_session_id?(@driver.execute_script("return window.beef.session.get_hook_session_id()"))).to eq true
		else
			expect(@hooks['hooked-browsers']['online']).not_to be_empty
		end
	end

	it 'browser details handler working' do
		print_info "Getting browser details"
		response = RestClient.get "#{RESTAPI_HOOKS}/#{@session}?token=#{@token}"
		details = JSON.parse(response.body)

		if details['browser.name.friendly'].downcase == 'internet explorer'
			browser_name = 'internet_explorer'
		else
			browser_name = details['browser.name.friendly'].downcase
		end

		expect(@driver.browser.to_s.downcase).to eq(browser_name)
	end
end
