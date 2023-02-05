#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module DNSRebinding
      extend BeEF::API::Extension

      @short_name  = 'DNS Rebinding'
      @full_name   = 'DNS Rebinding'
      @description = 'DNS Rebinding extension'
    end
  end
end

require 'extensions/dns_rebinding/api'
require 'extensions/dns_rebinding/dns_rebinding'
