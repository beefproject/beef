=begin

  Code in the 'ruby' folder are meants to patch ruby classes or
  gem classes.
  
  We use that to fix bugs or add functionalities to external code we
  are using.

=end


# Patching Ruby
require 'core/ruby/module'
require 'core/ruby/object'
require 'core/ruby/string'
require 'core/ruby/print'
require 'core/ruby/hash'

# Patching WebRick
require 'core/ruby/patches/webrick/httprequest'
require 'core/ruby/patches/webrick/cookie'
require 'core/ruby/patches/webrick/genericserver'
require 'core/ruby/patches/webrick/httpresponse'
require 'core/ruby/patches/webrick/httpservlet/filehandler.rb'
