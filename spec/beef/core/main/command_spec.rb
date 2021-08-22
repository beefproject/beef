RSpec.describe 'BeEF Command class testing' do
  it 'should return all beef configuration variables' do
    BeEF::Modules.load
    command_mock = BeEF::Core::Command.new('test_get_variable')
    expect(command_mock.config.beef_host).to eq('0.0.0.0')
    require 'modules/browser/hooked_domain/get_page_links/module'
    gpl = Get_page_links.new('test_get_variable')
    expect(gpl.config.beef_host).to eq('0.0.0.0')
    @config_instance = BeEF::Core::Configuration.instance
    @config_instance.set('beef.http.host', 'localhost')
    @config_instance.set('beef.http.port', nil)
    @config_instance.set('beef.https.enabled', true)
    @config_instance.set('beef.https.public_enabled', false)
    @config_instance.set('beef.http.public', nil)
    @config_instance.set('beef.http.public_port', nil)
    expect(@config_instance.get('beef.http.host')).to eq('localhost')
    expect(@config_instance.get('beef.http.port')).to eq(nil)
    expect(@config_instance.get('beef.https.enabled')).to eq(true)
    expect(@config_instance.get('beef.https.public_enabled')).to eq(false)
    expect(@config_instance.beef_url_str).to eq('https://localhost:3000')
    
  end
end
