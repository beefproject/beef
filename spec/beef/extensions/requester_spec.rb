require 'extensions/requester/extension'

RSpec.describe 'BeEF Extension Requester' do

  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config
  end

  it 'loads configuration' do
    expect(@config.get('beef.extension.requester')).to have_key('enable')
  end

  it 'has interface' do
    requester = BeEF::Extension::Requester::API::Hook.new
    expect(requester).to respond_to(:requester_run)
    expect(requester).to respond_to(:add_to_body)
    expect(requester).to respond_to(:requester_parse_db_request)
  end

  # default skipped because browser hooking not working properly in travis-CI
  xit 'requester works' do
    # start beef server
    
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
    # otr-activerecord require you to manually establish the connection with the following line
    #Also a check to confirm that the correct Gem version is installed to require it, likely easier for old systems.
    if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')
      OTR::ActiveRecord.establish_connection!
    end
# Migrate (if required)
    context = ActiveRecord::Migration.new.migration_context
    
    
    if context.needs_migration?
      puts "migrating db"
      ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration).migrate
    end


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

    https = BeEF::Core::Models::Http

    ### hook a new victim, use rest API to send request ###########

    api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, BEEF_PASSWD)
    response = api.auth()
    @token = response[:token]
    puts "authenticated. api token: #{@token}"

    response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {:token => @token}}
    puts "hooks response: #{response}"
    hb_details = JSON.parse(response.body)
    puts "hb_details is empty: #{hb_details.empty?}"
    while hb_details["hooked-browsers"]["online"].empty?
      # get victim session
      response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {:token => @token}}
      puts "hooks response: #{response}"
      hb_details = JSON.parse(response.body)
      puts "json: #{hb_details}"
      puts "online hooked browsers empty: #{hb_details["hooked-browsers"]["online"].empty?}"

      
    end

    hb_session = hb_details["hooked-browsers"]["online"]["0"]["session"]

    puts "hooked browser: #{hb_session}"

    # clear all previous victim requests
    cleared = https.where(:hooked_browser_id => hb_session).delete_all
    puts "cleared #{cleared} previous request entries"

    # send a random request to localhost port 3000
    randreq = (0...8).map { (65 + rand(26)).chr }.join

    response = RestClient.post "#{RESTAPI_REQUESTER}/send/#{hb_session}?token=#{@token}", "proto=http&raw_request=GET%20%2Ftest#{randreq}%20HTTP%2F1.1%0AHost%3A%20localhost%3A3000%0A"


    sleep 0.5
    sent_request = RestClient.get "#{RESTAPI_REQUESTER}/requests/#{hb_session}?token=#{@token}"

    puts "request sent: #{sent_request.to_json}"
    sent_request = JSON.parse(sent_request)
    reqid = sent_request["requests"][0]["id"]

    puts "getting response for id #{reqid}"
    
    response = RestClient.get "#{RESTAPI_REQUESTER}/response/#{reqid}?token=#{@token}"

    expect(response)

    ###############################################################

    # cleanup: delete test browser entries
    https.where(:hooked_browser_id => hb_session).delete_all

    # kill the server
    Process.kill('KILL', @pid)
    Process.kill('KILL', @pids)

    puts "waiting for server to die.."
    sleep 1
  end
end
