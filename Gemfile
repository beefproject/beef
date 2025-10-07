#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

gem 'net-smtp', require: false
gem 'json'

gem 'eventmachine', '~> 1.2', '>= 1.2.7'
gem 'thin', '~> 2.0'
gem 'sinatra', '~> 4.1'
gem 'rack', '~> 3.2'
gem 'rack-protection', '~> 4.1.1'
gem 'em-websocket', '~> 0.5.3' # WebSocket support
gem 'uglifier', '~> 4.2'
gem 'mime-types', '~> 3.7'
gem 'execjs', '~> 2.10'
gem 'ansi', '~> 1.5'
gem 'term-ansicolor', :require => 'term/ansicolor'
gem 'rubyzip', '~> 3.1'
gem 'espeak-ruby', '~> 1.1.0' # Text-to-Voice
gem 'rake', '~> 13.3'
gem 'activerecord', '~> 7.2' 
gem 'otr-activerecord', '~> 2.5.0'
gem 'sqlite3', '~> 2.7'
gem 'rubocop', '~> 1.81.1', require: false

# Geolocation support
group :geoip do
  gem 'maxmind-db', '~> 1.3'
end

gem 'parseconfig', '~> 1.1', '>= 1.1.2'
gem 'erubis', '~> 2.7'

# Metasploit Integration extension
group :ext_msf do
  gem 'msfrpc-client', '~> 1.1', '>= 1.1.2'
  gem 'xmlrpc', '~> 0.3.3'
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
  gem 'async-dns', '~> 1.4'
  gem 'async', '~> 1.32'
end

# QRcode extension
group :ext_qrcode do
  gem 'qr4r', '~> 0.6.1'
end

# For running unit tests
group :test do
    gem 'test-unit-full', '~> 0.0.5'
    gem 'rspec', '~> 3.13'
    gem 'rdoc', '~> 6.14'
    gem 'browserstack-local', '~> 1.4'

    gem 'irb', '~> 1.15'
    gem 'pry-byebug', '~> 3.11'

    gem 'rest-client', '~> 2.1.0'
    gem 'websocket-client-simple', '~> 0.6.1'

    # Note: curb gem requires curl libraries
    # sudo apt-get install libcurl4-openssl-dev
    gem 'curb', '~> 1.2'

    # Note: selenium-webdriver 3.x is incompatible with Firefox version 48 and prior
    # gem 'selenium' # Requires old version of selenium which is no longer available
    gem 'geckodriver-helper', '~> 0.24.0'
    gem 'selenium-webdriver', '~> 4.35'

    # Note: nokogiri is needed by capybara which may require one of the below commands
    # sudo apt-get install libxslt-dev libxml2-dev
    # sudo port install libxml2 libxslt
    gem 'capybara', '~> 3.40'
end

source 'https://rubygems.org'
