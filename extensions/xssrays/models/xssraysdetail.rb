#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Core
    module Models
      #
      # Store the rays details, basically verified XSS vulnerabilities
      #
      class Xssraysdetail < BeEF::Core::Model
        belongs_to :hooked_browser
        belongs_to :xssraysscan
      end
    end
  end
end
