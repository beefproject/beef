#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
module Extension
module Qrcode 

  module QrcodeGenerator

    BeEF::API::Registrar.instance.register(BeEF::Extension::Qrcode::QrcodeGenerator, BeEF::API::Server, 'pre_http_start')
    
    def self.pre_http_start(http_hook_server)
      require 'uri'

      fullurls = []
      partialurls = []

      configuration = BeEF::Core::Configuration.instance

      configuration.get("beef.extension.qrcode.target").each do |target|
        if target.lines.grep(/^https?:\/\//i).size > 0
          fullurls << target
        else
          partialurls << target
        end
      end

      if fullurls.size > 0
        print_success "Custom QRCode images available:"
        data = ""
        fullurls.each do |target|
          url = URI.escape(target,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          data += "https://chart.googleapis.com/chart?cht=qr&chs=#{configuration.get("beef.extension.qrcode.qrsize")}&chl=#{url}\n"
        end
        print_more data

      end
      
      if partialurls.size > 0
        BeEF::Core::Console::Banners.interfaces.each do |int|
          next if int == "localhost" or int == "127.0.0.1"
          print_success "QRCode images available for interface: #{int}"
          data = ""
          partialurls.each do |target|
            url = "http://#{int}:#{configuration.get("beef.http.port")}#{target}"
            url = URI.escape(url,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            data += "https://chart.googleapis.com/chart?cht=qr&chs=#{configuration.get("beef.extension.qrcode.qrsize")}&chl=#{url}\n"
          end
          print_more data
        end
      end
    end  
    
  end


end
end
end
