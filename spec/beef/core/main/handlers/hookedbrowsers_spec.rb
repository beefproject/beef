#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Handlers::HookedBrowsers do
  # .new returns Sinatra::Wrapper; use allocate to get the real class instance for unit testing
  let(:handler) { described_class.allocate }

  describe "GET '/'" do
    let(:config) { BeEF::Core::Configuration.instance }
    # Use a host permitted by Router's host_authorization (.localhost, .test, or config public host)
    let(:rack_env) { { 'REMOTE_ADDR' => '192.168.1.1', 'HTTP_HOST' => 'localhost' } }

    def app
      described_class
    end

    before do
      allow(BeEF::Core::Logger.instance).to receive(:register)
      allow(config).to receive(:get).and_call_original
      allow(config).to receive(:get).with('beef.http.restful_api.allow_cors').and_return(false)
    end

    it 'returns 404 when permitted_hooking_subnet is nil' do
      allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return(nil)
      get '/', {}, rack_env
      expect(last_response.status).to eq(404)
    end

    it 'returns 404 when permitted_hooking_subnet is empty' do
      allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return([])
      get '/', {}, rack_env
      expect(last_response.status).to eq(404)
    end

    it 'returns 404 when client IP is not in permitted subnet' do
      allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return(['10.0.0.0/8'])
      get '/', {}, rack_env
      expect(last_response.status).to eq(404)
    end

    it 'returns 404 when client IP is in excluded_hooking_subnet' do
      allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return(['0.0.0.0/0'])
      allow(config).to receive(:get).with('beef.restrictions.excluded_hooking_subnet').and_return(['192.168.1.0/24'])
      get '/', {}, rack_env
      expect(last_response.status).to eq(404)
    end

    it 'returns 200 and hook body when IP permitted, not excluded, no session (new browser)' do
      allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return(['192.168.0.0/16'])
      allow(config).to receive(:get).with('beef.restrictions.excluded_hooking_subnet').and_return([])
      allow(config).to receive(:get).with('beef.http.hook_session_name').and_return('beefhook')
      allow(BeEF::Core::Models::HookedBrowser).to receive(:where).and_return([])
      allow(BeEF::Filters).to receive(:is_valid_hostname?).with('localhost').and_return(true)
      allow(config).to receive(:get).with('beef.http.websocket.enable').and_return(false)
      allow_any_instance_of(described_class).to receive(:confirm_browser_user_agent).and_return(false)
      allow_any_instance_of(described_class).to receive(:legacy_build_beefjs!).with('localhost')
      get '/', {}, rack_env
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to include('javascript')
    end

    it 'uses multi_stage_beefjs when websocket disabled and confirm_browser_user_agent true' do
      allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return(['0.0.0.0/0'])
      allow(config).to receive(:get).with('beef.restrictions.excluded_hooking_subnet').and_return([])
      allow(config).to receive(:get).with('beef.http.hook_session_name').and_return('beefhook')
      allow(BeEF::Core::Models::HookedBrowser).to receive(:where).and_return([])
      allow(BeEF::Filters).to receive(:is_valid_hostname?).with('localhost').and_return(true)
      allow(config).to receive(:get).with('beef.http.websocket.enable').and_return(false)
      allow_any_instance_of(described_class).to receive(:confirm_browser_user_agent).and_return(true)
      allow_any_instance_of(described_class).to receive(:multi_stage_beefjs!).with('localhost')
      get '/', {}, { 'REMOTE_ADDR' => '127.0.0.1', 'HTTP_HOST' => 'localhost' }
      expect(last_response.status).to eq(200)
    end

    it 'returns early with empty body when hostname is invalid' do
      allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return(['0.0.0.0/0'])
      allow(config).to receive(:get).with('beef.restrictions.excluded_hooking_subnet').and_return([])
      allow(config).to receive(:get).with('beef.http.hook_session_name').and_return('beefhook')
      allow(BeEF::Core::Models::HookedBrowser).to receive(:where).and_return([])
      # Use permitted host so request reaches handler; stub hostname validation to fail
      allow(BeEF::Filters).to receive(:is_valid_hostname?).with('localhost').and_return(false)
      get '/', {}, { 'REMOTE_ADDR' => '127.0.0.1', 'HTTP_HOST' => 'localhost' }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('')
    end

    context 'when session exists (existing browser path)' do
      let(:hooked_browser) do
        double('HookedBrowser',
               id: 1,
               ip: '192.168.1.1',
               lastseen: Time.new.to_i - 120,
               session: 'existing_session',
               count!: nil,
               save!: true).tap do |d|
          allow(d).to receive(:lastseen=)
          allow(d).to receive(:ip=)
        end
      end

      before do
        allow(config).to receive(:get).with('beef.restrictions.permitted_hooking_subnet').and_return(['192.168.0.0/16'])
        allow(config).to receive(:get).with('beef.restrictions.excluded_hooking_subnet').and_return([])
        allow(config).to receive(:get).with('beef.http.hook_session_name').and_return('beefhook')
        allow(config).to receive(:get).with('beef.http.allow_reverse_proxy').and_return(false)
        relation = double('Relation', first: hooked_browser)
        allow(BeEF::Core::Models::HookedBrowser).to receive(:where).with(session: 'existing_session').and_return(relation)
        allow(BeEF::Core::Models::Command).to receive(:where).with(hooked_browser_id: 1, instructions_sent: false).and_return([])
        allow(BeEF::Core::Models::Execution).to receive(:where).with(is_sent: false, session_id: 'existing_session').and_return([])
        allow(BeEF::API::Registrar.instance).to receive(:fire)
      end

      it 'returns 200 and updates lastseen' do
        get '/', { 'beefhook' => 'existing_session' }, rack_env
        expect(last_response.status).to eq(200)
        expect(hooked_browser).to have_received(:save!)
      end

      it 'logs zombie comeback when lastseen was more than 60 seconds ago' do
        get '/', { 'beefhook' => 'existing_session' }, rack_env
        expect(BeEF::Core::Logger.instance).to have_received(:register).with('Zombie', /appears to have come back online/, '1')
      end

      it 'calls add_command_instructions for each pending command' do
        command = double('Command', id: 1, command_module_id: 1)
        allow(BeEF::Core::Models::Command).to receive(:where).with(hooked_browser_id: 1, instructions_sent: false).and_return([command])
        expect_any_instance_of(described_class).to receive(:add_command_instructions).with(command, hooked_browser)
        get '/', { 'beefhook' => 'existing_session' }, rack_env
      end
    end
  end

  describe '#confirm_browser_user_agent' do
    it 'returns true when user_agent suffix matches a legacy UA string' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return(['IE 8.0'])

      # browser_type = user_agent.split(' ').last => '8.0'; 'IE 8.0'.include?('8.0') => true
      expect(handler.confirm_browser_user_agent('Mozilla/5.0 IE 8.0')).to be true
    end

    it 'returns true when first legacy UA matches' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return(['IE 8.0', 'Firefox/3.6'])

      expect(handler.confirm_browser_user_agent('Mozilla/5.0 IE 8.0')).to be true
    end

    it 'returns false when no legacy UA includes the browser type' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return([])

      expect(handler.confirm_browser_user_agent('Mozilla/5.0 Chrome/91.0')).to be false
    end

    it 'returns false when legacy list has entries but none match' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return(['IE 8.0'])

      expect(handler.confirm_browser_user_agent('Chrome/91.0')).to be false
    end
  end
end
