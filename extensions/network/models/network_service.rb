#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Table stores each open port identified on the zombie browser's network(s)
      #
      class NetworkService

        include DataMapper::Resource
        storage_names[:default] = 'network_service'

        property :id, Serial

        property :hooked_browser_id, Text, :lazy => false
        property :proto, String, :lazy => false
        property :ip, Text, :lazy => false
        property :port, String, :lazy => false
        property :type, String, :lazy => false
        property :cid, String, :lazy => false # command id or 'init'

      end

    end
  end
end
