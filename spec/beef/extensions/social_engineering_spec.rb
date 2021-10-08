require 'extensions/social_engineering/models/web_cloner'
require 'extensions/social_engineering/web_cloner/web_cloner'
require 'extensions/social_engineering/web_cloner/interceptor'
require 'extensions/social_engineering/models/interceptor'
require 'fileutils'

RSpec.describe 'BeEF Extension Social Engineering' do

  it 'persistence web cloner' do
    expect {
      BeEF::Core::Models::WebCloner.create(uri: "example.com", mount: "/")
    }.to_not raise_error
  end

  xit 'clone web page' do
    expect {
      BeEF::Core::Server.instance.prepare
      BeEF::Extension::SocialEngineering::WebCloner.instance.clone_page("https://www.google.com", "/", nil, nil)
    }.to_not raise_error
    FileUtils.rm(Dir['./extensions/social_engineering/web_cloner/cloned_pages/www.google.com'])
    FileUtils.rm(Dir['./extensions/social_engineering/web_cloner/cloned_pages/www.google.com_mod'])
  end
end
