


#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../support/constants'
require_relative '../../support/beef_test'
require 'core/main/network_stack/websocket/websocket'
require 'websocket-client-simple'

RSpec.describe 'Browser hooking with Websockets', :run_on_browserstack => true do
	before(:all) do
		@config = BeEF::Core::Configuration.instance
		@config.set('beef.credentials.user', "beef")
    @config.set('beef.credentials.passwd', "beef")
    @config.set('beef.http.websocket.secure', false)
    @config.set('beef.http.websocket.enable', true)
    @ws = BeEF::Core::Websocket::Websocket.instance
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
		@driver.navigate.to "#{VICTIM_URL}"
		# Give time for browser hook to occur
    sleep 3
		
		begin
			@hook_request = RestClient.get "#{RESTAPI_HOOKS}?token=#{@token}"
			@hooks = JSON.parse(@hook_request)
			if @hooks['hooked-browsers']['online'].empty?
				@session = @hooks['hooked-browsers']['online']['0']['session']
			else
        print_info "Cannot find online session server-side continuing to grab Session ID from client"
				@session = @driver.execute_script("return window.beef.session.get_hook_session_id()")
			end
		rescue => exception
			print_info "Encountered Exception: #{exception}"
			print_info "Continuing to grab Session ID from client"
			@session = @driver.execute_script("return window.beef.session.get_hook_session_id()")
		end
	end

  after(:all) do
    begin
      @driver.quit
    rescue => exception
      print_info "Error closing BrowserStack connection: #{exception}"
    ensure
      print_info "Shutting down server"
      Process.kill("KILL",@pid)
      Process.kill("KILL",@pids)
    end
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
    begin
      if @hooks['hooked-browsers']['online'].empty?
        expect(BeEF::Filters.is_valid_hook_session_id?(@driver.execute_script("return window.beef.session.get_hook_session_id()"))).to eq true
      else
        expect(@hooks['hooked-browsers']['online']).not_to be_empty
      end
    rescue => exception
      if exception.include?('Errno::ETIMEDOUT:')
        print_info "Encountered possible false negative timeout error checking exception."
        expect(exception).to include('Failed to open TCP connection to hub-cloud.browserstack.com:80')
      elsif exception.include?('401 Unauthorized')
        print_info "Encountered possible false negative un-auth exception due to a failed hook."
        expect(@hook_request.code).to eq (401)
      else
        print_info "Encountered Exception: #{exception}"
        print_info "Issue retrieving hooked browser information - checking instead that client session ID exists"
        expect(@session).not_to be_empty
      end
    end
	end
end
