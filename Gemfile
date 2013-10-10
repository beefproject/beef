# BeEF's Gemfile

#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Gems only required on Windows, or with specific Windows issues
if RUBY_PLATFORM.downcase.include?("mswin") || RUBY_PLATFORM.downcase.include?("mingw")
  gem "win32console"
end

gem "eventmachine", "1.0.3"
gem "thin"
gem "sinatra", "1.4.2"
gem "rack", "1.5.2"
gem "em-websocket", "~> 0.3.6"
gem "uglifier", "~> 2.2.1"
# install https://github.com/cowboyd/therubyracer if the OS is != than OSX
if !RUBY_PLATFORM.downcase.include?("darwin")
  gem "therubyracer", "~> 0.12.0"
end
gem "ansi"
gem "term-ansicolor", :require => "term/ansicolor"
gem "dm-core"
gem "json"
gem "data_objects"
gem "dm-sqlite-adapter"
gem "parseconfig"
gem "erubis"
gem "dm-migrations"
gem "msfrpc-client"
gem "rubyzip", "~> 1.0.0"

# notifications
gem "twitter"

if ENV['BEEF_TEST']
# for running unit tests
  gem "test-unit"
  gem "test-unit-full"
  gem "curb"
  gem "test-unit"
  gem "selenium"
  gem "selenium-webdriver"
  # nokogirl is needed by capybara which may require one of the below commands
  # sudo apt-get install libxslt-dev libxml2-dev
  # sudo port install libxml2 libxslt
  gem "capybara"
  #RESTful API tests/generic command module tests
  gem "rest-client", "~> 1.6.7"
end

source "http://rubygems.org"
