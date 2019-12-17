require 'extensions/qrcode/extension'

RSpec.describe 'BeEF Extension QRCode' do

  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config
  end

  it 'loads configuration' do
    config = @config.get('beef.extension.qrcode')
    expect(config).to have_key('enable')
    expect(config).to have_key('targets')
    expect(config).to have_key('qrsize')
    expect(config).to have_key('qrborder')
  end

end
