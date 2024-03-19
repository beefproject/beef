#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'net/http'
require 'uri'

RSpec.describe 'BeEF API Rate Limit' do

    def start_beef_server
		@config = BeEF::Core::Configuration.instance
		@config.set('beef.credentials.user', "beef")
		@config.set('beef.credentials.passwd', "beef")
		@username = @config.get('beef.credentials.user')
		@password = @config.get('beef.credentials.passwd')
		
		# Load BeEF extensions
		# Always load Extensions, as previous changes to the config from other tests may affect
		# whether or not this test passes.
		BeEF::Extensions.load

		# Load BeEF modules
        # Check if modules already loaded. No need to reload.
		if @config.get('beef.module').nil?
			BeEF::Modules.load
		else
			print_info "Modules already loaded"
		end

		# Grab DB file and regenerate if requested
		db_file = @config.get('beef.database.file')

		if BeEF::Core::Console::CommandLine.parse[:resetdb]
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
		BeEF::Core::Migration.instance.update_db!

		# Spawn HTTP Server
		# print_info "Starting HTTP Hook Server"
		http_hook_server = BeEF::Core::Server.instance
		http_hook_server.prepare

		# Generate a token for the server to respond with
		BeEF::Core::Crypto::api_token

		# Initiate server start-up
		BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
		pid = fork do
			http_hook_server.start
		end

        return pid
    end

    def beef_server_running?(uri_str)
      uri = URI.parse(uri_str)
      response = Net::HTTP.get_response(uri)
      response.is_a?(Net::HTTPSuccess)
    rescue
      false
    end
    
    def wait_for_beef_server_to_start(uri_str, timeout: 30)
      start_time = Time.now
    
      until beef_server_running?(uri_str) || (Time.now - start_time) > timeout do
        sleep 0.1
      end
    
      beef_server_running?(uri_str)
    end
    
    def start_beef_server_and_wait
      pid = start_beef_server
    
      if wait_for_beef_server_to_start('http://localhost:3000', timeout: 30)
        # print_info "Server started successfully."
      else
        print_info "Server failed to start within timeout."
      end
    
      pid
    end
    
	before(:all) do
        @pid = start_beef_server_and_wait
	end

	after(:all) do
		print_info "Shutting down server"
		Process.kill("KILL",@pid) unless @pid.nil?
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
			(0..50).each do |i|
				test_api = apis[i%l]
				expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
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
			  end
		  apis.shuffle! # new order for next iteration
		  apis = apis.reverse if (apis[0].is_pass?(BEEF_PASSWD)) # prevent the first from having valid passwd
		end                         # multiple sets of auth attempts
	end
 
end
