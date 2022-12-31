#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Store the XssRays scans started and finished, with relative ID
      #
      class Xssraysscan < BeEF::Core::Model
        has_many :xssrays_details
      end
    end
  end
end
