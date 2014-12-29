#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module ETag

  extend BeEF::API::Extension

  @short_name  = 'ETag'
  @full_name   = 'Server-to-Client ETag-based Covert Timing Channel'
  @description = 'This extension provides a custom BeEF\'s HTTP server ' + 
                 'that implement unidirectional covert timing channel from ' +
                 'BeEF communication server to zombie browser over Etag header'

end
end
end

require 'extensions/etag/api.rb'
require 'extensions/etag/etag.rb'
