# BeEF's Gemfile

#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

gem 'eventmachine'
gem 'puma'

# TODO REMOVE THIN
gem 'thin'

# TODO remove unicorn
gem 'unicorn'

gem 'sinatra'
# gem 'rack', '~> 1.6.4'
gem 'em-websocket' # WebSocket support
gem 'uglifier'
gem 'mime-types'


# Windows support
# TODO re-enable this when the WebUI is reenabled
# if RUBY_PLATFORM.downcase.include?('mswin') || RUBY_PLATFORM.downcase.include?('mingw')
#   # make sure you install this gem following https://github.com/eakmotion/therubyracer_for_windows
#   gem 'therubyracer'
# elsif !RUBY_PLATFORM.downcase.include?('darwin')
#   gem 'therubyracer'
# end
 
gem 'execjs'
gem 'ansi'
gem 'term-ansicolor', :require => 'term/ansicolor'
gem 'dm-core'
gem 'json'
gem 'data_objects'
gem 'rubyzip', '>= 1.0.0'
gem 'espeak-ruby', '>= 1.0.3' # Text-to-Voice


# SQLite support
group :sqlite do
  gem 'dm-sqlite-adapter'
end

# PostgreSQL support
group :postgres do
  #gem dm-postgres-adapter
end

# MySQL support
group :mysql do
  #gem dm-mysql-adapter
end

# Geolocation support
group :geoip do
  gem 'geoip'
end

gem 'parseconfig'
gem 'erubis'
gem 'dm-migrations'

# Metasploit Integration extension
group :ext_msf do
  gem 'msfrpc-client'
end

# Twitter Notifications extension
group :ext_twitter do
  #gem 'twitter', '>= 5.0.0'
end

# DNS extension
group :ext_dns do
  gem 'rubydns', '~> 0.7.3'
end

# network extension
group :ext_network do
  gem 'dm-serializer'
end

# QRcode extension
group :ext_qrcode do
  gem 'qr4r'
end

# For running unit tests
group :test do
if ENV['BEEF_TEST']
  gem 'test-unit'
  gem 'test-unit-full'
  gem 'curb'
  gem 'selenium'
  gem 'selenium-webdriver'
  gem 'rspec'
  gem 'bundler-audit'
  # nokogirl is needed by capybara which may require one of the below commands
  # sudo apt-get install libxslt-dev libxml2-dev
  # sudo port install libxml2 libxslt
  gem 'capybara'
  # RESTful API tests/generic command module tests
  gem 'rest-client', '>= 1.8.0'
end
end

source 'https://rubygems.org'
