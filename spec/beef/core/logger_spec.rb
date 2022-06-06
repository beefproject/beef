
RSpec.describe 'BeEF thin Logger', run_on_browserstack: true do

	before(:all) do
        require 'byebug';byebug
		@config = BeEF::Core::Configuration.instance
		@config.set('beef.credentials.user', "beef")
		@config.set('beef.credentials.passwd', "beef")
		@config.set('beef.http.debug', "true")
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
		Process.kill("KILL",@pid)
		Process.kill("KILL",@pids)
	end
	
    it 'thin logger does not raise an error' do
        # The thin logging being enabled should not cause an error in response
        test_api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, 'beef')
        expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed
    end
  
end
