#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      class Webcloner

        include DataMapper::Resource

        storage_names[:default] = 'extension_seng_webcloner'

        property :id, Serial

        property :uri, Text, :lazy => false
        property :mount, Text, :lazy => false

        has n, :extension_seng_interceptor, 'Interceptor'

      end

    end
  end
end
