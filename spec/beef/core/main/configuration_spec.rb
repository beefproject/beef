#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.configure do |config|
end

RSpec.describe 'BeEF Configuration' do

  before(:context) do
    @config_instance = BeEF::Core::Configuration.instance

    @original_http_host = @config_instance.get('beef.http.host')
    @original_http_port = @config_instance.get('beef.http.port')
    @original_http_https = @config_instance.get('beef.http.https.enable')
    @original_http_public_host = @config_instance.get('beef.http.public.host')
    @original_http_public_port = @config_instance.get('beef.http.public.port')
    @original_http_public_https = @config_instance.get('beef.http.public.https')
    @original_http_hook_file = @config_instance.get('beef.http.hook_file')
  end

  after(:context) do
    # Reset the configuration values
    # This is important as the tests may change the configuration values
    @config_instance.set('beef.http.host', @original_http_host)
    @config_instance.set('beef.http.port', @original_http_port)
    @config_instance.set('beef.http.https.enable', @original_http_https)
    @config_instance.set('beef.http.public.host', @original_http_public_host)
    @config_instance.set('beef.http.public.port', @original_http_public_port)
    @config_instance.set('beef.http.public.https', @original_http_public_https)
    @config_instance.set('beef.http.hook_file', @original_http_hook_file)
  end

  context 'http local host configuration values' do
    it 'should set the local host value to 0.0.0.0' do
      @config_instance.set('beef.http.host', '0.0.0.0')
      expect(@config_instance.get('beef.http.host')).to eq('0.0.0.0')
    end

    it 'should get the local host value' do
      @config_instance.set('beef.http.host', '0.0.0.0')
      expect(@config_instance.local_host).to eq('0.0.0.0')
    end

    it 'should get the default host value' do
      @config_instance.set('beef.http.host', nil)
      expect(@config_instance.get('beef.http.host')).to eq(nil)
      expect(@config_instance.local_host).to eq('0.0.0.0')
    end
  end

  context 'http local port configuration values' do
    it 'should set the local port value to 3000' do
      @config_instance.set('beef.http.port', '3000')
      expect(@config_instance.get('beef.http.port')).to eq('3000')
    end

    it 'should get the local port value' do
      @config_instance.set('beef.http.port', '3000')
      expect(@config_instance.local_port).to eq('3000')
    end

    it 'should get the default port value' do
      @config_instance.set('beef.http.port', nil)
      expect(@config_instance.get('beef.http.port')).to eq(nil)
      expect(@config_instance.local_port).to eq('3000')
    end
  end

  context 'beef https enabled configuration values' do
    it 'should set the https enabled config value' do
      @config_instance.set('beef.http.https.enable', true)
      expect(@config_instance.get('beef.http.https.enable')).to eq(true)
    end

    it 'should get https enabled value set to true' do
      @config_instance.set('beef.http.https.enable', true)
      expect(@config_instance.local_https_enabled).to eq(true)
    end

    it 'should get https enabled value set to false' do
      @config_instance.set('beef.http.https.enable', false)
      expect(@config_instance.local_https_enabled).to eq(false)
    end

    it 'should get the default https enabled value' do
      @config_instance.set('beef.http.https.enable', nil)
      expect(@config_instance.get('beef.http.https.enable')).to eq(nil)
      expect(@config_instance.local_https_enabled).to eq(false)
    end
  end

  #public
  context 'http public host configuration values' do
    it 'should set the public host value to example.com' do
      @config_instance.set('beef.http.public.host', 'example.com')
      expect(@config_instance.get('beef.http.public.host')).to eq('example.com')
    end

    it 'should get the public host value' do
      @config_instance.set('beef.http.public.host', 'example.com')
      expect(@config_instance.public_host).to eq('example.com')
    end

    it 'should get nil host value' do
      @config_instance.set('beef.http.public.host', nil)
      expect(@config_instance.get('beef.http.public.host')).to eq(nil)
      expect(@config_instance.public_host).to eq(nil)
    end
  end

  context 'http public port configuration values' do
    it 'should set the public port value to 3000' do
      @config_instance.set('beef.http.public.port', '443')
      expect(@config_instance.get('beef.http.public.port')).to eq('443')
    end

    it 'should get the public port value' do
      @config_instance.set('beef.http.public.port', '3000')
      expect(@config_instance.public_port).to eq('3000')
    end

    it 'should return 80 as the port given a public host has been set and https disabled' do
      @config_instance.set('beef.http.public.port', nil)
      @config_instance.set('beef.http.public.host', 'example.com')
      @config_instance.set('beef.http.public.https', false)
      expect(@config_instance.get('beef.http.public.port')).to eq(nil)
      expect(@config_instance.get('beef.http.public.host')).to eq('example.com')
      expect(@config_instance.public_port).to eq('80')
    end
  end

  context 'beef https enabled configuration values' do
    it 'should set the https enabled config value' do
      @config_instance.set('beef.http.https.enable', true)
      expect(@config_instance.get('beef.http.https.enable')).to eq(true)
    end

    it 'should get https enabled value set to true' do
      @config_instance.set('beef.http.public.https', true)
      expect(@config_instance.public_https_enabled?).to eq(true)
    end

    it 'should get https enabled value set to false' do
      @config_instance.set('beef.http.public.https', false)
      expect(@config_instance.public_https_enabled?).to eq(false)
    end

    it 'should get the default https to false' do
      @config_instance.set('beef.http.public.https', nil)
      expect(@config_instance.get('beef.http.public.https')).to eq(nil)
      expect(@config_instance.public_https_enabled?).to eq(false)
    end

    it 'should return public port as 443 if public https is enabled' do
      @config_instance.set('beef.http.public.https', true)
      @config_instance.set('beef.http.public.port', nil)
      expect(@config_instance.get('beef.http.public.https')).to eq(true)
      expect(@config_instance.get('beef.http.public.port')).to eq(nil)
      expect(@config_instance.public_https_enabled?).to eq(true)
      expect(@config_instance.public_port).to eq('443')
    end
  end

  context 'beef hosting information' do
    it 'should return the local host value because a public has not been set' do
      @config_instance.set('beef.http.host', 'asdqwe')
      @config_instance.set('beef.http.public.host', nil)
      expect(@config_instance.get('beef.http.host')).to eq('asdqwe')
      expect(@config_instance.get('beef.http.public.host')).to eq(nil)
      expect(@config_instance.beef_host).to eq('asdqwe')
    end

    it 'should return the public host value because a public has been set' do
      @config_instance.set('beef.http.host', 'asdqwe')
      @config_instance.set('beef.http.public.host', 'poilkj')
      expect(@config_instance.get('beef.http.host')).to eq('asdqwe')
      expect(@config_instance.get('beef.http.public.host')).to eq('poilkj')
      expect(@config_instance.beef_host).to eq('poilkj')
    end

    it 'should return the local port value because a public value has not been set' do
      @config_instance.set('beef.http.port', '3000')
      @config_instance.set('beef.http.public.host', nil)
      @config_instance.set('beef.http.public.port', nil)
      @config_instance.set('beef.http.public.https', nil)
      expect(@config_instance.get('beef.http.port')).to eq('3000')
      expect(@config_instance.get('beef.http.public.port')).to eq(nil)
      expect(@config_instance.get('beef.http.public.host')).to eq(nil)
      expect(@config_instance.get('beef.http.public.https')).to eq(nil)
      expect(@config_instance.beef_port).to eq('3000')
    end

    it 'should return the public host value because a public has been set' do
      @config_instance.set('beef.http.port', '3000')
      @config_instance.set('beef.http.public.port', '80')
      @config_instance.set('beef.http.public.host', nil)
      expect(@config_instance.get('beef.http.port')).to eq('3000')
      expect(@config_instance.get('beef.http.public.port')).to eq('80')
      expect(@config_instance.get('beef.http.public.host')).to eq(nil)
      expect(@config_instance.beef_port).to eq('80')
    end
    
    it 'should return a protocol https if https public has been enabled and public host is set' do
      @config_instance.set('beef.http.public.https', true)
      @config_instance.set('beef.http.public.host', 'public')
      expect(@config_instance.get('beef.http.public.https')).to eq(true)
      expect(@config_instance.beef_proto).to eq('https')
    end

    it 'should return a protocol http if public is not set and https local is fales'  do
      @config_instance.set('beef.http.public.https', false)
      @config_instance.set('beef.http.https.enable', false)
      expect(@config_instance.get('beef.http.public.https')).to eq(false)
      expect(@config_instance.beef_proto).to eq('http')
    end

    it 'should return the full url string for beef local http and port 80' do
      @config_instance.set('beef.http.host', 'localhost')
      @config_instance.set('beef.http.port', '80')
      @config_instance.set('beef.http.https.enable', false)
      @config_instance.set('beef.http.public.https', false)
      @config_instance.set('beef.http.public.host', nil)
      @config_instance.set('beef.http.public.port', nil)
      expect(@config_instance.get('beef.http.host')).to eq('localhost')
      expect(@config_instance.get('beef.http.port')).to eq('80')
      expect(@config_instance.get('beef.http.https.enable')).to eq(false)
      expect(@config_instance.get('beef.http.public.https')).to eq(false)
      expect(@config_instance.beef_url_str).to eq('http://localhost:80')
    end

    it 'should return the full url string for beef https localhost 3000 default' do
      @config_instance.set('beef.http.host', 'localhost')
      @config_instance.set('beef.http.port', nil)
      @config_instance.set('beef.http.https.enable', true)
      @config_instance.set('beef.http.public.host', nil)
      @config_instance.set('beef.http.public.https', false)
      @config_instance.set('beef.http.public.host', nil)
      @config_instance.set('beef.http.public.port', nil)
      expect(@config_instance.get('beef.http.host')).to eq('localhost')
      expect(@config_instance.get('beef.http.port')).to eq(nil)
      expect(@config_instance.get('beef.http.https.enable')).to eq(true)
      expect(@config_instance.get('beef.http.public.https')).to eq(false)
      expect(@config_instance.beef_url_str).to eq('https://localhost:3000')
    end

    it 'should return the full url string for beef hook url' do
      @config_instance.set('beef.http.host', 'localhost')
      @config_instance.set('beef.http.port', nil)
      @config_instance.set('beef.http.https.enable', true)
      @config_instance.set('beef.http.public.https', false)
      @config_instance.set('beef.http.public.host', nil)
      @config_instance.set('beef.http.public.port', nil)
      @config_instance.set('beef.http.hook_file', '/hook.js')
      expect(@config_instance.get('beef.http.host')).to eq('localhost')
      expect(@config_instance.get('beef.http.port')).to eq(nil)
      expect(@config_instance.get('beef.http.https.enable')).to eq(true)
      expect(@config_instance.get('beef.http.public.https')).to eq(false)
      expect(@config_instance.get('beef.http.hook_file')).to eq('/hook.js')
      expect(@config_instance.beef_url_str).to eq('https://localhost:3000')
      expect(@config_instance.hook_url).to eq('https://localhost:3000/hook.js')
    end
  end
end
