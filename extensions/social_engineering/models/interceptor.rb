#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      class Interceptor

        include DataMapper::Resource

        storage_names[:default] = 'extension_seng_interceptor'

        property :id, Serial
        property :ip, Text, :lazy => false
        property :post_data, Text, :lazy => false

        belongs_to :webcloner

      end

    end
  end
end
