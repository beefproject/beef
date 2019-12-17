require 'extensions/ipec/extension'

RSpec.describe 'BeEF Extension IPEC' do

  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config
  end

  it 'loads configuration' do
    expect(@config.get('beef.extension.ipec')).to have_key('enable')
  end

  it 'interface' do
    expect(BeEF::Extension::Ipec::JunkCalculator.instance).to respond_to(:bind_junk_calculator)
  end

end
