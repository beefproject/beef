#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'extensions/proxy/extension'

RSpec.describe 'BeEF Extension Proxy' do

  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config
  end

  it 'loads configuration' do
    config = @config.get('beef.extension.proxy')
    expect(config).to have_key('enable')
    expect(config).to have_key('address')
    expect(config).to have_key('port')
    expect(config).to have_key('key')
    expect(config).to have_key('cert')
  end

end
