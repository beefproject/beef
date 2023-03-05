#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
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
	 
	it 'adheres to auth rate limits' do
		passwds = (1..9).map { |i| "broken_pass"}
		passwds.push BEEF_PASSWD
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, pswd) }
		l = apis.length
		#If this is failing with expect(test_api.auth()[:payload]["success"]).to be(true) expected true but received nil
		#make sure in config.yaml the password = BEEF_PASSWD, which is currently 'beef'
		(0..2).each do |again|      # multiple sets of auth attempts
		  # first pass -- apis in order, valid passwd on 9th attempt
		  # subsequent passes apis shuffled
		  puts "speed requesets"    # all should return 401
		  (0..50).each do |i|
			# t = Time.now()
			#puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"
			test_api = apis[i%l]
			expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
			# t0 = t
		  end
		  # again with more time between calls -- there should be success (1st iteration)
		  puts "delayed requests"
		  (0..(l*2)).each do |i|
			# t = Time.now()
			#puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"
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
