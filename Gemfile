#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#gem 'simplecov', require: false, group: :test

gem 'net-smtp', require: false
gem 'json'

gem 'eventmachine', '~> 1.2', '>= 1.2.7'
gem 'thin', '~> 1.8'
gem 'sinatra', '~> 3.0', '>= 3.0.5'
gem 'rack', '~> 2.2', '>= 2.2.4'
gem 'rack-protection', '~> 3.0.5'
gem 'em-websocket', '~> 0.5.3' # WebSocket support
gem 'uglifier', '~> 4.2'
gem 'mime-types', '~> 3.4', '>= 3.4.1'
gem 'execjs', '~> 2.8', '>= 2.8.1'
gem 'ansi', '~> 1.5'
gem 'term-ansicolor', :require => 'term/ansicolor'
gem 'rubyzip', '~> 2.3'
gem 'espeak-ruby', '~> 1.1.0' # Text-to-Voice
gem 'rake', '~> 13.0'
gem 'otr-activerecord', '~> 2.1', '>= 2.1.2'
gem 'sqlite3', '~> 1.6', '>= 1.6.1'
gem 'rubocop', '~> 1.48.1', require: false

# Geolocation support
group :geoip do
  gem 'maxmind-db', '~> 1.1', '>= 1.1.1'
end

gem 'parseconfig', '~> 1.1', '>= 1.1.2'
gem 'erubis', '~> 2.7'

# Metasploit Integration extension
group :ext_msf do
  gem 'msfrpc-client', '~> 1.1', '>= 1.1.2'
  gem 'xmlrpc', '~> 0.3.2'
end

# Notifications extension
group :ext_notifications do
  # Pushover
  gem 'rushover', '~> 0.3.0'
  # Slack
  gem 'slack-notifier', '~> 2.4'
end

# DNS extension
group :ext_dns do
  gem 'async-dns', '~> 1.3'
  gem 'async', '~> 1.31'
end

# QRcode extension
group :ext_qrcode do
  gem 'qr4r', '~> 0.6.1'
end

# For running unit tests
group :test do
    gem 'test-unit-full', '~> 0.0.5'
    gem 'rspec', '~> 3.12'
    gem 'rdoc', '~> 6.5'
    gem 'browserstack-local', '~> 1.4'

    gem 'irb', '~> 1.6', '>= 1.6.3'
    gem 'pry-byebug', '~> 3.10', '>= 3.10.1'

    gem 'rest-client', '~> 2.1.0'
    gem 'websocket-client-simple', '~> 0.6.1'

    # curb gem requires curl libraries
    # sudo apt-get install libcurl4-openssl-dev
    gem 'curb', '~> 1.0', '>= 1.0.5'

    # selenium-webdriver 3.x is incompatible with Firefox version 48 and prior
    # gem 'selenium' # Requires old version of selenium which is no longer available
    gem 'geckodriver-helper', '~> 0.24.0'
    gem 'selenium-webdriver', '~> 4.8', '>= 4.8.1'

    # nokogiri is needed by capybara which may require one of the below commands
    # sudo apt-get install libxslt-dev libxml2-dev
    # sudo port install libxml2 libxslt
    gem 'capybara', '~> 3.38'
end

source 'https://rubygems.org'
