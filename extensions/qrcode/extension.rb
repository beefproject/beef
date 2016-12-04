#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Qrcode
  
  extend BeEF::API::Extension
  
  @short_name = 'qrcode'
  @full_name = 'QR Code Generator'
  @description = 'This extension generates QR Codes for specified URLs which can be used to hook browsers into BeEF.'

end
end
end

require 'extensions/qrcode/qrcode'
