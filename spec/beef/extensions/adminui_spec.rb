# 
# Tests for handling access to the Admin UI
# 

require 'extensions/admin_ui/classes/httpcontroller'
require 'extensions/admin_ui/classes/session'
require 'extensions/admin_ui/controllers/authentication/authentication'

RSpec.describe 'BeEF Extension AdminUI' do
  before(:all) do
    @session = BeEF::Extension::AdminUI::Session.instance
    @config = BeEF::Core::Configuration.instance
  end

  after(:all) do
    @config.set('beef.restrictions.permitted_ui_subnet',["0.0.0.0/0", "::/0"])
  end

  it 'loads configuration' do
    expect(@config.get('beef.restrictions')).to have_key('permitted_ui_subnet')
  end

  it 'confirms that any ip address is permitted to view the admin ui' do
    ui = BeEF::Extension::AdminUI::HttpController.new
    expect(@config.set('beef.restrictions.permitted_ui_subnet',["0.0.0.0/0", "::/0"])).to eq true
    expect(ui.authenticate_request("8.8.8.8")).to eq true
  end

  it 'confirms that an ip address is permitted to view the admin ui' do
    ui = BeEF::Extension::AdminUI::HttpController.new
    expect(@config.set('beef.restrictions.permitted_ui_subnet',["192.168.10.1"])).to eq true
    expect(ui.authenticate_request("192.168.10.1")).to eq true
  end

  it 'confirms that an ip address is not permitted to view the admin ui' do
    ui = BeEF::Extension::AdminUI::HttpController.new
    expect(@config.set('beef.restrictions.permitted_ui_subnet',["10.10.10.1"])).to eq true
    expect(ui.authenticate_request("8.8.8.8")).to eq false
  end

  it 'confirms that X-Forwarded-For cant be spoofed when reverse proxy is disabled' do
    ui = BeEF::Extension::AdminUI::HttpController.new
    expect(@config.set('beef.restrictions.permitted_ui_subnet',["192.168.0.10"])).to eq true
    expect(@config.set('beef.http.allow_reverse_proxy',false)).to eq true
    env = { "REQUEST_METHOD" => "GET", "PATH_INFO" => "/ui/authentication" }
    request = Rack::Request.new(env) 
    request.add_header("HTTP_X_FORWARDED_FOR","192.168.0.10")
    request.add_header("REMOTE_ADDR","192.168.0.20")
    expect(ui.get_ip(request)).to eq "192.168.0.20"
  end

end