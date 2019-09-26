RSpec.describe 'BeEF Extension Console' do

  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config
  end

  it 'loads configuration' do
    expect(@config.get('beef.extension.console')).to have_key('enable')
    console_shell = @config.get('beef.extension.console.shell')
    expect(console_shell).to have_key('historyfolder')
    expect(console_shell).to have_key('historyfile')
  end

end
