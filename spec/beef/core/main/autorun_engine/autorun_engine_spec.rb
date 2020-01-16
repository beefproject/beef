RSpec.describe 'AutoRunEngine test' do

	before(:all) do
		# Note: rake spec passes --patterns which causes BeEF to pickup this argument via optparse. I can't see a better way at the moment to filter this out. Therefore ARGV=[] for this test.
		ARGV = []
		@config = BeEF::Core::Configuration.instance
		@config.set('beef.credentials.user', "beef")
		@config.set('beef.credentials.passwd', "beef")
		
		#generate api token
		BeEF::Core::Crypto::api_token

		# load up DB
		# Connect to DB
		ActiveRecord::Base.logger = nil
		OTR::ActiveRecord.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
		OTR::ActiveRecord.configure_from_hash!(adapter:'sqlite3', database:'beef.db')
		# Migrate (if required)
		context = ActiveRecord::Migration.new.migration_context
		if context.needs_migration?
		  ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration).migrate
		end



		# add AutoRunEngine rule
		test_rule =  {"name"=>"Display an alert", "author"=>"mgeeky", "browser"=>"ALL", "browser_version"=>"ALL", "os"=>"ALL", "os_version"=>"ALL", "modules"=>[{"name"=>"alert_dialog", "condition"=>nil, "options"=>{"text"=>"You've been BeEFed ;>"}}], "execution_order"=>[0], "execution_delay"=>[0], "chain_mode"=>"sequential"}

		BeEF::Core::AutorunEngine::RuleLoader.instance.load_directory
		# are_engine.R


		http_hook_server = BeEF::Core::Server.instance
		http_hook_server.prepare


		@pids = fork do
			BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
		end
		@pid = fork do
			http_hook_server.start
		end
		# wait for server to start
		sleep 1
	end
    # wait for server to start
  
  	after(:all) do
	
	   Process.kill("KILL",@pid)
	   Process.kill("KILL",@pids)
	
 	end

	it 'AutoRunEngine is working' do

		api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, BEEF_PASSWD)

		response = api.auth()

		@token = response[:token]

		puts "authenticated. api token: #{@token}"

		puts 'hooking a new victim, waiting a few seconds...'

		victim = BeefTest.new_victim
      	sleep 5.0

      	response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {:token => @token}}

      	j = JSON.parse(response.body)
      	expect(j)

	end
 
end
