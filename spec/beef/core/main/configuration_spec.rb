RSpec.describe 'BeEF Configuration' do
  before(:all) do
    @config_instance = BeEF::Core::Configuration.instance
  end
  it 'should set the local host value to 0.0.0.0' do
    @config_instance.set('beef.http.host', '0.0.0.0')
    expect(@config_instance.get('beef.http.host')).to eq('0.0.0.0')
  end

  it 'should get the local host value' do
    @config_instance.set('beef.http.host', '0.0.0.0')
    expect(@config_instance.local_host).to eq('0.0.0.0')
  end
end
