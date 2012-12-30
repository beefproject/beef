#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Qrcode
  
  extend BeEF::API::Extension
  
  @short_name = 'qrcode'
  @full_name = 'QR Code Generator'
  @description = 'This extension prints out a link to a QR Code which can be used to hook browsers into BeEF'

end
end
end

require 'extensions/qrcode/qrcode'