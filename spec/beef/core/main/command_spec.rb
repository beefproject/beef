RSpec.describe 'BeEF Core Command Class specs' do
  before(:example) do
    BeEF::Modules.load
  end

  it 'should have a configuration object accessable from class instance' do
    command = BeEF::Core::Command.new('get_visited_urls')
    command.config.set('beef.http.host', 'localhost')
    expect(command.config.beef_host).to eq('localhost')
  end
end
