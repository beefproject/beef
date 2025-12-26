#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Qrcode
      module QrcodeGenerator
        BeEF::API::Registrar.instance.register(BeEF::Extension::Qrcode::QrcodeGenerator, BeEF::API::Server, 'pre_http_start')

        def self.pre_http_start(_http_hook_server)
          require 'uri'
          require 'qr4r'

          fullurls = []

          # get server config
          configuration = BeEF::Core::Configuration.instance
          beef_proto = configuration.beef_proto
          beef_host  = configuration.beef_host
          beef_port  = configuration.beef_port

          # get URLs from QR config
          configuration.get('beef.extension.qrcode.targets').each do |target|
            # absolute URLs
            if target.lines.grep(%r{^https?://}i).size.positive?
              fullurls << target
            # relative URLs
            else
              
              # Retrieve the list of network interfaces from BeEF::Core::Console::Banners
              interfaces = BeEF::Core::Console::Banners.interfaces

              if not interfaces.nil? and not interfaces.empty? # If interfaces are available, iterate over each network interface
                # If interfaces are available, iterate over each network interface
                interfaces.each do |int|
                  # Skip the loop iteration if the interface address is '0.0.0.0' (which generally represents all IPv4 addresses on the local machine)
                  next if int == '0.0.0.0'
                  # Construct full URLs using the network interface address, and add them to the fullurls array
                  # The URL is composed of the BeEF protocol, interface address, BeEF port, and the target path
                  fullurls << "#{beef_proto}://#{int}:#{beef_port}#{target}"
                end
              end

            end
          end

          return unless fullurls.empty?

          img_dir = 'extensions/qrcode/images'
          begin
            Dir.mkdir(img_dir) unless File.directory?(img_dir)
          rescue StandardError
            print_error "[QR] Could not create directory '#{img_dir}'"
          end

          data = ''
          fullurls.uniq.each do |target|
            fname = ('a'..'z').to_a.sample(8).join
            qr_path = "#{img_dir}/#{fname}.png"
            begin
              Qr4r.encode(
                target, qr_path, {
                  pixel_size: configuration.get('beef.extension.qrcode.qrsize'),
                  border: configuration.get('beef.extension.qrcode.qrborder')
                }
              )
            rescue StandardError
              print_error "[QR] Could not write file '#{qr_path}'"
              next
            end

            print_debug "[QR] Wrote file '#{qr_path}'"
            BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind(
              "/#{qr_path}", "/qrcode/#{fname}", 'png'
            )

            data += "#{beef_proto}://#{beef_host}:#{beef_port}/qrcode/#{fname}.png\n"
            data += "- URL: #{target}\n"
            # Google API
            # url = URI::Parser.new.escape(target,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            # w = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
            # h = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
            # data += "- Google API: https://chart.googleapis.com/chart?cht=qr&chs=#{w}x#{h}&chl=#{url}\n"
            # QRServer.com
            # url = URI::Parser.new.escape(target,Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
            # w = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
            # h = configuration.get("beef.extension.qrcode.qrsize").to_i * 100
            # data += "- QRServer API: https://api.qrserver.com/v1/create-qr-code/?size=#{w}x#{h}&data=#{url}\n"
          end

          print_info 'QR code images available:'
          print_more data
        end
      end
    end
  end
end
