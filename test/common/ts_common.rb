#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# @note Version check to ensure BeEF is running Ruby 1.9 >
if  RUBY_VERSION < '1.9'
  puts "\n"
  puts "Ruby version " + RUBY_VERSION + " is no longer supported. Please upgrade 1.9 or later."
  puts "\n"
  exit
end

begin
  require 'test/unit/ui/console/testrunner'
rescue LoadError
  puts "The following instruction failed: require 'test/unit/ui/console/testrunner'"
  puts "Please run: sudo gem install test-unit-full"
  exit
end

