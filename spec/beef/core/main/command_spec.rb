RSpec.describe 'BeEF Command class testing' do
  before(:each) do
    # Reset or re-initialise the configuration to a default state
    @config_instance = BeEF::Core::Configuration.instance  
  end

  it 'should return a beef configuration variable' do
    BeEF::Modules.load
    command_mock = BeEF::Core::Command.new('test_get_variable')
    expect(command_mock.config.beef_host).to eq('0.0.0.0')

    require 'modules/browser/hooked_domain/get_page_links/module'
    gpl = Get_page_links.new('test_get_variable')
    expect(gpl.config.beef_host).to eq('0.0.0.0')
  end
end
