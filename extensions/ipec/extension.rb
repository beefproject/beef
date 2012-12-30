#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension

  #todo remove it from here:
  # Handlers
  #require 'extensions/ipec/fingerprinter'
  #require 'extensions/ipec/launcher'
  require 'extensions/ipec/junk_calculator'

  module Ipec
    extend BeEF::API::Extension

    @short_name = 'Ipec'
    @full_name = 'Inter-Protocol Exploitation'
    @description = "Use the Inter-Protocol Exploitation technique to send shellcode to daemons implementing 'tolerant' protocols."

    module RegisterIpecRestHandler
      def self.mount_handler(server)
        server.mount('/api/ipec', BeEF::Extension::Ipec::IpecRest.new)
      end
    end

    BeEF::API::Registrar.instance.register(BeEF::Extension::Ipec::RegisterIpecRestHandler, BeEF::API::Server, 'mount_handler')

    #todo remove it from here, and make it dynamic.
    BeEF::Extension::Ipec::JunkCalculator.instance.bind_junk_calculator("imapeudora1")
  end
end
end

# Models
# todo: to be used when we'll have more IPEC exploits
#require 'extensions/ipec/models/ipec_exploits'
#require 'extensions/ipec/models/ipec_exploits_run'

# RESTful api endpoints
require 'extensions/ipec/rest/ipec'








