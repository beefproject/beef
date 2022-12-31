#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module ETag
      extend BeEF::API::Extension

      @short_name  = 'ETag'
      @full_name   = 'Server-to-Client ETag-based Covert Timing Channel'
      @description = 'This extension provides a custom BeEF HTTP server ' \
                     'that implements unidirectional covert timing channel from ' \
                     'BeEF communication server to zombie browser over Etag header.'
    end
  end
end

require 'extensions/etag/api'
require 'extensions/etag/etag'
