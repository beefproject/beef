#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#gem 'simplecov', require: false, group: :test

gem 'net-smtp', require: false

gem 'eventmachine'
gem 'thin'
gem 'sinatra', '>= 2.2.0'
gem 'rack', '>= 2.2.4'
gem 'rack-protection', '>= 2.2.0'
gem 'em-websocket' # WebSocket support
gem 'uglifier', '>= 4.2.0'
gem 'mime-types'
gem 'execjs'
gem 'ansi'
gem 'term-ansicolor', :require => 'term/ansicolor'
gem 'json'
gem 'rubyzip', '>= 1.2.2'
gem 'espeak-ruby', '>= 1.0.4' # Text-to-Voice
gem 'rake', '>= 13.0'
gem 'otr-activerecord', '>= 1.4.2'
gem 'sqlite3'
gem 'rubocop', '~> 1.48.0', require: false

# Geolocation support
group :geoip do
  gem 'maxmind-db'
end

gem 'parseconfig'
gem 'erubis'

# Metasploit Integration extension
group :ext_msf do
  gem 'msfrpc-client'
  gem 'xmlrpc'
end

# Notifications extension
group :ext_notifications do
  gem 'unf'
  gem 'domain_name', '>= 0.5.20190701'
  # Pushover
  gem 'rushover'
  # Slack
  gem 'slack-notifier'
  # Twitter
  gem 'twitter', '>= 7.0.0'
end

# DNS extension
group :ext_dns do
  gem 'async-dns'
end

# QRcode extension
group :ext_qrcode do
  gem 'qr4r'
end

# For running unit tests
group :test do
    gem 'test-unit'
    gem 'test-unit-full'
    gem 'rspec'
    gem 'rdoc'
    # curb gem requires curl libraries
    # sudo apt-get install libcurl4-openssl-dev
    gem 'curb'
    # selenium-webdriver 3.x is incompatible with Firefox version 48 and prior
    # gem 'selenium' # Requires old version of selenium which is no longer available
    gem 'geckodriver-helper'
    gem 'selenium-webdriver'
    # nokogirl is needed by capybara which may require one of the below commands
    # sudo apt-get install libxslt-dev libxml2-dev
    # sudo port install libxml2 libxslt
    gem 'capybara'
    # RESTful API tests/generic command module tests
    gem 'rest-client', '>= 2.1.0'
    gem 'irb'
    gem 'pry-byebug'
    gem "websocket-client-simple", "~> 0.6.0"
    gem "browserstack-local", "~> 1.4"
end

source 'https://rubygems.org'
