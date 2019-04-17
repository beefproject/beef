require 'extensions/network/models/network_service'
require 'extensions/network/models/network_host'

RSpec.describe 'BeEF Extension Network' do

  before(:all) do
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end

  it 'add good host' do
    expect {
      BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => '1234', :ip => '127.0.0.1')
    }.to_not raise_error
    expect(BeEF::Core::Models::NetworkHost.all(hooked_browser_id: '1234', ip: '127.0.0.1')).to_not be_empty
  end

  it 'add good service' do
    expect {
      BeEF::Core::Models::NetworkService.add(:hooked_browser_id => '1234', :proto => 'http', :ip => '127.0.0.1', :port => 80, :type => 'Apache')
    }.to_not raise_error
    expect(BeEF::Core::Models::NetworkService.all(hooked_browser_id: '1234', ip: '127.0.0.1')).to_not be_empty

  end

end
