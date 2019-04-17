require 'extensions/requester/extension'

RSpec.describe 'BeEF Extension Requester' do

  before(:all) do
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config
  end

  it 'loads configuration' do
    expect(@config.get('beef.extension.requester')).to have_key('enable')
  end

  it 'has interface' do
    requester = BeEF::Extension::Requester::API::Hook.new
    expect(requester).to respond_to(:requester_run)
    expect(requester).to respond_to(:add_to_body)
    expect(requester).to respond_to(:requester_parse_db_request)
  end

end
