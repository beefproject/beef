#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module ServerClientDnsTunnel

      extend BeEF::API::Extension
      @short_name   = 'S2C DNS Tunnel'
      @full_name    = 'Server-to-Client DNS Tunnel'
      @description  = 'This extension provides a custom BeEF\'s DNS server and HTTP server ' +
                      'that implement unidirectional covert timing channel from BeEF communication server to zombie browser.'

    end
  end
end

require 'extensions/s2c_dns_tunnel/dnsd'
require 'extensions/s2c_dns_tunnel/api'
require 'extensions/s2c_dns_tunnel/httpd'
