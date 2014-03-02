# BeEF's Gemfile

#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

gem "eventmachine", "1.0.3"
gem "thin"
gem "sinatra", "1.4.2"
gem "rack", "1.5.2"
gem "em-websocket", "~> 0.3.6"
gem "uglifier", "~> 2.2.1"
if RUBY_PLATFORM.downcase.include?("mswin") || RUBY_PLATFORM.downcase.include?("mingw")
  # make sure you install this gem following https://github.com/hiranpeiris/therubyracer_for_windows
  gem "therubyracer", "~> 0.11.0beta1"
  gem "execjs"
  gem "win32console"
elsif !RUBY_PLATFORM.downcase.include?("darwin")
  gem "therubyracer"
  gem "execjs"
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
gem "rubyzip", ">= 1.0.0"
gem "rubydns"
gem "sourcify"

# notifications
gem "twitter", ">= 5.0.0"

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
