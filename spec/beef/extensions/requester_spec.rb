require 'extensions/requester/extension'

#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
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

  xit 'requester works' do
    begin
      ar_snapshot = SpecActiveRecordConnection.snapshot
      # Start beef server
      @config = BeEF::Core::Configuration.instance
      @config.set('beef.credentials.user', 'beef')
      @config.set('beef.credentials.passwd', 'beef')
      
      # Generate API token
      BeEF::Core::Crypto::api_token

      # Connect to DB
      ActiveRecord::Base.logger = nil
      OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: 'beef.db')
      OTR::ActiveRecord.establish_connection! if Gem.loaded_specs['otr-activerecord'].version > Gem::Version.create('1.4.2')

      # Migrate if required
      ActiveRecord::Migrator.migrations_paths = [File.join('core', 'main', 'ar-migrations')]
      context = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
      ActiveRecord::Migrator.new(:up, context.migrations, context.schema_migration, context.internal_metadata).migrate if context.needs_migration?

      # Start HTTP hook server
      http_hook_server = BeEF::Core::Server.instance
      http_hook_server.prepare
      @pids = fork { BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server) }
      @pid = fork { http_hook_server.start }

      # Wait for server to start
      sleep 2

      # Hook a new victim and use REST API to send request
      api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, BEEF_PASSWD)
      response = api.auth()
      @token = response[:token]

      while (response = RestClient.get("#{RESTAPI_HOOKS}", {params: {token: @token}})) &&
            (hb_details = JSON.parse(response.body)) &&
            hb_details['hooked-browsers']['online'].empty?
        sleep 2
      end

      hb_session = hb_details['hooked-browsers']['online']['0']['session']
      randreq = (0...8).map { (65 + rand(26)).chr }.join
      RestClient.post("#{RESTAPI_REQUESTER}/send/#{hb_session}?token=#{@token}", "proto=http&raw_request=GET%20%2Ftest#{randreq}%20HTTP%2F1.1%0AHost%3A%20localhost%3A3000%0A")

      sleep 2
      sent_request = RestClient.get("#{RESTAPI_REQUESTER}/requests/#{hb_session}?token=#{@token}")
      reqid = JSON.parse(sent_request)['requests'][0]['id']

      response = RestClient.get("#{RESTAPI_REQUESTER}/response/#{reqid}?token=#{@token}")
      expect(response)
    ensure
      # Clean up
      BeEF::Core::Models::Http.where(hooked_browser_id: hb_session).delete_all if defined? hb_session
      Process.kill('KILL', @pid) if defined? @pid
      Process.kill('KILL', @pids) if defined? @pids
      SpecActiveRecordConnection.restore!(ar_snapshot)
    end
  end
end
