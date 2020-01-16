require 'extensions/network/models/network_service'
require 'extensions/network/models/network_host'

RSpec.describe 'BeEF Extension Network' do

  it 'add good local host' do
    expect {
      BeEF::Core::Models::NetworkHost.create(:hooked_browser_id => '1234', :ip => '127.0.0.1')
    }.to_not raise_error
    expect(BeEF::Core::Models::NetworkHost.where(hooked_browser_id: '1234', ip: '127.0.0.1')).to_not be_empty
  end

  it 'add good not local host' do
    expect {
      BeEF::Core::Models::NetworkHost.create(:hooked_browser_id => '12', :ip => '192.168.1.2')
    }.to_not raise_error
    expect(BeEF::Core::Models::NetworkHost.where(hooked_browser_id: '12', ip: '192.168.1.2')).to_not be_empty
  end

  it 'add good service' do
    expect {
      BeEF::Core::Models::NetworkService.create(:hooked_browser_id => '1234', :proto => 'http', :ip => '127.0.0.1', :port => 80, :ntype => 'Apache')
    }.to_not raise_error
    expect(BeEF::Core::Models::NetworkService.where(hooked_browser_id: '1234', ip: '127.0.0.1')).to_not be_empty

  end

end
