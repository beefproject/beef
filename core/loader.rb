#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# @note Include here all the gems we are using
require 'rubygems'
require 'bundler/setup'

# For some reason, on Ruby 2.5+, msgpack needs to be loaded first,
# else metasploit integration dies due to undefined `to_msgpack`.
# Works fine on Ruby 2.4
require 'msgpack'

Bundler.require(:default)

require 'cgi'
require 'yaml'
require 'singleton'
require 'ipaddr'
require 'base64'
require 'xmlrpc/client'
require 'openssl'
require 'eventmachine'
require 'thin'
require 'rack'
require 'em-websocket'
require 'uglifier'
require 'execjs'
require 'ansi'
require 'term/ansicolor'
require 'json'
require 'otr-activerecord'
require 'parseconfig'
require 'erubis'
require 'mime/types'
require 'optparse'
require 'resolv'
require 'digest'
require 'zip'
require 'logger'
# @note Logger
require 'core/logger'

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
