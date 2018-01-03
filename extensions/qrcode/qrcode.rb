#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
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
      require 'qr4r'

      fullurls = []

      # get server config
      configuration = BeEF::Core::Configuration.instance
      beef_proto = configuration.get('beef.http.https.enable') == true ? "https" : "http"
      beef_host  = configuration.get("beef.http.public") || configuration.get("beef.http.host")
      beef_port  = configuration.get("beef.http.public_port") || configuration.get("beef.http.port")

      # get URLs from QR config
      configuration.get("beef.extension.qrcode.targets").each do |target|
        # absolute URLs
        if target.lines.grep(/^https?:\/\//i).size > 0
          fullurls << target
        # relative URLs
        else
          # network interfaces
          BeEF::Core::Console::Banners.interfaces.each do |int|
            next if int == "0.0.0.0"
            fullurls << "#{beef_proto}://#{int}:#{beef_port}#{target}"
          end
          # beef host
          unless beef_host == "0.0.0.0"
            fullurls << "#{beef_proto}://#{beef_host}:#{beef_port}#{target}"
          end
        end
      end

      unless fullurls.empty?
        img_dir = 'extensions/qrcode/images'
        begin
          Dir.mkdir(img_dir) unless File.directory?(img_dir)
        rescue
          print_error "[QR] Could not create directory '#{img_dir}'"
        end
        data = ''
        fullurls.uniq.each do |target|
          fname = ('a'..'z').to_a.shuffle[0,8].join
          qr_path = "#{img_dir}/#{fname}.png"
          begin
            qr = Qr4r::encode(
              target, qr_path, {
                :pixel_size => configuration.get("beef.extension.qrcode.qrsize"),
                :border => configuration.get("beef.extension.qrcode.qrborder")
              })
          rescue
            print_error "[QR] Could not write file '#{qr_path}'"
            next
          end
          print_debug "[QR] Wrote file '#{qr_path}'"
          BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(
            "/#{qr_path}", "/qrcode/#{fname}", 'png')
          data += "#{beef_proto}://#{beef_host}:#{beef_port}/qrcode/#{fname}.png\n"
          data += "- URL: #{target}\n"
          # Google API
          #url = URI.escape(target,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          #w = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
          #h = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
          #data += "- Google API: https://chart.googleapis.com/chart?cht=qr&chs=#{w}x#{h}&chl=#{url}\n"
          # QRServer.com
          #url = URI.escape(target,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          #w = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
          #h = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
          #data += "- QRServer API: https://api.qrserver.com/v1/create-qr-code/?size=#{w}x#{h}&data=#{url}\n"
        end
        print_info "QR code images available:"
        print_more data
      end
    end  
    
  end

end
end
end
