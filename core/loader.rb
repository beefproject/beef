#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# @note Include here all the gems we are using
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'cgi'
require 'yaml'
require 'singleton'
require 'ipaddr'
require 'base64'
require 'xmlrpc/client'
require 'openssl'

# @note Include the filters
require 'core/filters'

# @note Include our patches for ruby and gems
require 'core/ruby'

# @note Include the API
require 'core/api'

# @note Include the settings
require 'core/settings'

# @note Include the core of BeEF
require 'core/core'