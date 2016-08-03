#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Waf_handler

      extend BeEF::API::Extension

      @short_name  = 'waf_handler'
      @full_name   = 'WAF Detection'
      @description = 'This module identifies and fingerprints Web Application Firewall (WAF) products.'

    end
  end
end

require 'extensions/waf_handler/api'
require 'extensions/waf_handler/waf_handler'
