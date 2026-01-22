RSpec.describe 'BeEF Command class testing' do
  let(:config) { BeEF::Core::Configuration.instance }

  before do
    # Ensure modules are loaded
    BeEF::Modules.load if config.get('beef.module').nil?

    # Set up a test module configuration if it doesn't exist
    unless config.get('beef.module.test_get_variable')
      config.set('beef.module.test_get_variable.name', 'Test Get Variable')
      config.set('beef.module.test_get_variable.path', 'modules/test/')
      config.set('beef.module.test_get_variable.mount', '/command/test_get_variable.js')
      config.set('beef.module.test_get_variable.db.id', 1)
    end
  end

  it 'should return a beef configuration variable' do
    expect do
      command_mock = BeEF::Core::Command.new('test_get_variable')
      expect(command_mock.config.beef_host).to eq('0.0.0.0')
    end.to_not raise_error
  end
end
