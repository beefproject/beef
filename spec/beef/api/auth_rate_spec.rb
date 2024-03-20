#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'net/http'
require 'uri'

RSpec.describe 'BeEF API Rate Limit' do

    def configure_beef
        @config = BeEF::Core::Configuration.instance

        @config.set('beef.credentials.user', "beef")
        @config.set('beef.credentials.passwd', "beef")

        @username = @config.get('beef.credentials.user')
        @password = @config.get('beef.credentials.passwd')
    end

    def load_beef_extensions_and_modules
        # Load BeEF extensions
        BeEF::Extensions.load

        # Load BeEF modules only if they are not already loaded
        BeEF::Modules.load if @config.get('beef.module').nil?
    end

    def start_beef_server
        configure_beef
        load_beef_extensions_and_modules

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
    
    def wait_for_beef_server_to_start(uri_str, timeout: 5)
      start_time = Time.now
    
      until beef_server_running?(uri_str) || (Time.now - start_time) > timeout do
        sleep 0.1
      end
    
      beef_server_running?(uri_str)
    end
    
    def start_beef_server_and_wait
      pid = start_beef_server
    
      if wait_for_beef_server_to_start('http://localhost:3000', timeout: 5)
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
		# Shutting down server
        Process.kill("KILL", @pid) unless @pid.nil?
        Process.wait(@pid) # Ensure the process has exited and the port is released
        @pid = nil
	end

    it 'confirm correct creds are successful' do

        sleep 0.5
        test_api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, BEEF_PASSWD) 
        expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed

    end
    
    it 'confirm incorrect creds are unsuccessful' do

        sleep 0.5
        test_api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, "wrong_passowrd") 
        expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
    end
    
    it 'adheres to 9 bad passwords then 1 correct auth rate limits' do

        # create api structures with bad passwords and one good
		passwds = (1..9).map { |i| "bad_password"} # incorrect password
		passwds.push BEEF_PASSWD # correct password
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, pswd) }

        (0..apis.length-1).each do |i|
            test_api = apis[i]
            expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
        end
    end
    
    it 'adheres to random bad passords and 1 correct auth rate limits' do

        # create api structures with bad passwords and one good
		passwds = (1..9).map { |i| "bad_password"} # incorrect password
		passwds.push BEEF_PASSWD # correct password
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, pswd) }

        apis.shuffle! # random order for next iteration
        apis = apis.reverse if (apis[0].is_pass?(BEEF_PASSWD)) # prevent the first from having valid passwd

        (0..apis.length-1).each do |i|
            test_api = apis[i]
            if (test_api.is_pass?(BEEF_PASSWD))
                sleep(0.5)
                expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed
            else
                expect(test_api.auth()[:payload]).to eql("401 Unauthorized")
            end
        end
    end    
 
end
