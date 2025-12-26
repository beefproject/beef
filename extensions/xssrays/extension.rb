#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Xssrays
    end
  end
end

require 'extensions/xssrays/models/xssraysscan'
require 'extensions/xssrays/models/xssraysdetail'
require 'extensions/xssrays/api/scan'
require 'extensions/xssrays/handler'
require 'extensions/xssrays/api'
require 'extensions/xssrays/rest/xssrays'
