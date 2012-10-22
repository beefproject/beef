#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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








