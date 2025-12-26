#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'extensions/social_engineering/models/web_cloner'
require 'extensions/social_engineering/web_cloner/web_cloner'
require 'extensions/social_engineering/web_cloner/interceptor'
require 'extensions/social_engineering/models/interceptor'
require 'fileutils'

RSpec.describe 'BeEF Extension Social Engineering' do
  it 'checks if wget exists' do
    expect(`which wget`).to include('/wget')
  end

  context 'when wget exists' do
    before(:each) do
      allow_any_instance_of(BeEF::Extension::SocialEngineering::WebCloner).to receive(:system).and_return(false) # Stub to simulate failure
    end

    xit 'clone web page', if: !`which wget`.empty? do
      expect {
        BeEF::Core::Server.instance.prepare
        BeEF::Extension::SocialEngineering::WebCloner.instance.clone_page("https://www.google.com", "/", nil, nil)
      }.to_not raise_error
    end

    it 'persistence web cloner', if: !`which wget`.empty? do
      expect {
        BeEF::Core::Models::WebCloner.create(uri: "example.com", mount: "/")
      }.to_not raise_error
    end
  end
end
