#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# @note Version check to ensure BeEF is running Ruby 2.0+
if RUBY_VERSION < '2.2'
  puts "\n"
  puts "Ruby version #{RUBY_VERSION} is no longer supported. Please upgrade to Ruby version 2.2 or later."
  puts "\n"
  exit 1
end

begin
  require 'test/unit/ui/console/testrunner'
rescue LoadError
  puts "The following instruction failed: require 'test/unit/ui/console/testrunner'"
  puts "Please run: sudo gem install test-unit-full"
  exit
end

