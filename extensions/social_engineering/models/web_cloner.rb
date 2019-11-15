#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      class Webcloner <  ActiveRecord::Base
        attribute :id, :Serial

        attribute :uri, :Text, :lazy => false
        attribute :mount, :Text, :lazy => false

        belongs_tos :extension_seng_interceptor, 'Interceptor'
      end

    end
  end
end
