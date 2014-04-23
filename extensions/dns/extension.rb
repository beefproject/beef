#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Dns

      extend BeEF::API::Extension

      @short_name = 'dns'
      @full_name = 'DNS Server'
      @description = 'A configurable DNS nameserver for performing DNS spoofing, ' +
          'hijacking, and other related attacks against hooked browsers.'

    end
  end
end

require 'extensions/dns/api'
require 'extensions/dns/dns'
require 'extensions/dns/logger'
require 'extensions/dns/model'
# @todo Uncomment when RESTful API is DNS 2.0 compliant.
#require 'extensions/dns/rest/dns'
