RSpec.describe 'BeEF Command class testing' do
  it 'should return a beef configuration variable' do
    expect {
      BeEF::Modules.load if BeEF::Core::Configuration.instance.get('beef.module').nil?
    }.to_not raise_error
    command_mock = BeEF::Core::Command.new('test_get_variable')
    expect(command_mock.config.beef_host).to eq('0.0.0.0')

    require 'modules/browser/hooked_origin/get_page_links/module'
    gpl = Get_page_links.new('test_get_variable')
    expect(gpl.config.beef_host).to eq('0.0.0.0')
  end
end
