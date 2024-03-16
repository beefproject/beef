#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF API Rate Limit' do

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
			File.delete(db_file) if File.exist?(db_file)
		end

		# Load up DB and migrate if necessary
		ActiveRecord::Base.logger = nil
		OTR::ActiveRecord.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
		OTR::ActiveRecord.configure_from_hash!(adapter:'sqlite3', database: db_file)
		# otr-activerecord require you to manually establish the connection with the following line
		#Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
		if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
			OTR::ActiveRecord.establish_connection!
  		end

		# Migrate (if required)
		ActiveRecord::Migration.verbose = false # silence activerecord migration stdout messages
		context = ActiveRecord::Migration.new.migration_context
		if context.needs_migration?
  			ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration, context.internal_metadata).migrate
		end

		sleep 2

		BeEF::Core::Migration.instance.update_db!

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
		sleep 3

		# Try to connect 3 times 
		(0..2).each do |again|   
			# Authenticate to REST API & pull the token from the response
			if @response.nil?
				print_info "Try to connect: " + again.to_s
				begin
					creds = { 'username': "#{@username}", 'password': "#{@password}" }.to_json
					@response = RestClient.post "#{RESTAPI_ADMIN}/login", creds, :content_type => :json
				rescue RestClient::ServerBrokeConnection, Errno::ECONNREFUSED # likely to be starting up still
				rescue => error
					print_error error.message
				end
				print_info "Rescue: sleep for 10 and try to connect again"
				sleep 10
			end
		end
		expect(@response) .to be_truthy # confirm the test has connected to the server
		print_info "Connection with server was successful"
		@token = JSON.parse(@response)['token']
	end
  
	after(:all) do
		print_info "Shutting down server"
		Process.kill("KILL",@pid) unless @pid.nil?
		Process.kill("KILL",@pids) unless @pid.nil?
	end
	 
	it 'adheres to auth rate limits' do
		passwds = (1..9).map { |i| "broken_pass"}
		passwds.push BEEF_PASSWD
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, pswd) }
		l = apis.length
		(0..2).each do |again|      # multiple sets of auth attempts
		  # first pass -- apis in order, valid passwd on 9th attempt
		  # subsequent passes apis shuffled
		  print_info "Starting authentication attempt sequence #{again + 1}. The valid password is placed randomly among failed attempts."
		#   print_info 'FILL THIS IN'
		#   puts "speed requesets"    # all should return 401
		  (0..50).each do |i|
			test_api = apis[i%l]
			expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
			# t0 = t
		  end
		  # again with more time between calls -- there should be success (1st iteration)
	    print_info "Initiating delayed authentication requests to test successful authentication with correct credentials."
    	print_info "Delayed requests are made to simulate more realistic login attempts and verify rate limiting."
		  (0..(l*2)).each do |i|
			test_api = apis[i%l]
			if (test_api.is_pass?(BEEF_PASSWD))
				expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed
			else
				expect(test_api.auth()[:payload]).to eql("401 Unauthorized")
			end
			sleep(0.5)
			# t0 = t
		  end
		  apis.shuffle! # new order for next iteration
		  apis = apis.reverse if (apis[0].is_pass?(BEEF_PASSWD)) # prevent the first from having valid passwd
		end                         # multiple sets of auth attempts
	end
 
end
