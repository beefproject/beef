#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
module BeEF
module Extension
module Qrcode 

  module QrcodeGenerator

    BeEF::API::Registrar.instance.register(BeEF::Extension::Qrcode::QrcodeGenerator, BeEF::API::Server, 'pre_http_start')
    
    def self.pre_http_start(http_hook_server)
      require 'uri'
      
      configuration = BeEF::Core::Configuration.instance
      BeEF::Core::Console::Banners.interfaces.each do |int|
        next if int == "localhost" or int == "127.0.0.1"
        print_success "QRCode images available for interface: #{int}"
        data = ""
        configuration.get("beef.extension.qrcode.target").each do |target|
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
