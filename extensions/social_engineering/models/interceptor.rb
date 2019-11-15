#
# Copyright (c) 2006-2019 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      class Interceptor < ActiveRecord::Base
        attribute :id, :Serial
        attribute :ip, :Text, :lazy => false
        attribute :post_data, :Text, :lazy => false

        belongs_to :webcloner

      end

    end
  end
end
