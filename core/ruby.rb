#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# @note Patching Ruby Security
require 'core/ruby/security'

# @note Patching Rack File class to prevent a potential XSS
require 'core/ruby/file.rb'

# @note Patching Ruby
require 'core/ruby/module'
require 'core/ruby/object'
require 'core/ruby/string'
require 'core/ruby/print'
require 'core/ruby/hash'

# @note Patching DataMapper Data Objects Adapter (dm-do-adapter)
require 'core/ruby/patches/dm-do-adapter/adapter.rb'

