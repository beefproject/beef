#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class S2c_dns_tunnel < BeEF::Core::Command

  def self.options

    @configuration = BeEF::Core::Configuration.instance
    zone    = @configuration.get("beef.extension.s2c_dns_tunnel.zone");
    port    = @configuration.get("beef.http.port");
    scheme  = @configuration.get("beef.http.https.enable") == true ? "https" : "http"

    return [
            {'name' => 'payload_name', 'ui_label'=>'Payload Name', 'type' => 'text', 'width' => '400px', 'value' => 'dnsTunnelPayload'},
            {'name' => 'zone', 'ui_label'=>'Zone', 'type' => 'hidden', 'width' => '400px', 'value' => zone},
            {'name' => 'port', 'ui_label'=>'Port', 'type' => 'hidden', 'width' => '400px', 'value' => port},
            {'name' => 'scheme', 'ui_label'=>'Scheme', 'type' => 'hidden', 'width' => '400px', 'value' => scheme},
            {'name' => 'data', 'ui_label'=>'Message', 'type' => 'textarea', 
             'value' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ' +
                        'ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco ' +
                        'laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in ' +
                        'voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat ' +
                        'non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
             'width' => '400px', 'height' => '100px'}
           ]
  end

  def pre_send
    @configuration = BeEF::Core::Configuration.instance
    enable = @configuration.get("beef.extension.s2c_dns_tunnel.enable");
    raise ArgumentError,'s2c_dns_tunnel extension is disabled' if enable != true

    # gets the value configured in the module configuration by the user  
    @datastore.each do |input|
      if input['name'] == "data"
        @data = input['value']
      end
    end

    BeEF::Extension::ServerClientDnsTunnel::Server.instance.messages.store(@command_id.to_i ,@data.unpack("B*")[0])
  end

  def post_execute

    # gets the value of command_id from BeEF database and delete the message from DNS "database"
    cid = @datastore['cid'].to_i
    BeEF::Extension::ServerClientDnsTunnel::Server.instance.messages.delete(cid)

  end

end
