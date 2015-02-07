#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Cross_origin_scanner < BeEF::Core::Command

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true

      session_id = @datastore['beefhook']
      cid = @datastore['cid'].to_i

      # log the network service
      if @datastore['results'] =~ /ip=(.+)&port=([\d]+)&status/
        ip = $1
        port = $2
        proto = 'http'
        type = 'HTTP Server (CORS)'
        print_debug("Hooked browser found HTTP server #{ip}:#{port}")
        if !ip.nil? && !port.nil? && BeEF::Filters.is_valid_ip?(ip) && BeEF::Core::Models::NetworkService.all(:hooked_browser_id => session_id, :proto => proto, :ip => ip, :port => port, :type => type).empty?
          r = BeEF::Core::Models::NetworkService.new(:hooked_browser_id => session_id, :proto => proto, :ip => ip, :port => port, :type => type, :cid => cid)
          r.save
          if BeEF::Core::Models::NetworkHost.all(:hooked_browser_id => session_id, :ip => ip).empty?
            r = BeEF::Core::Models::NetworkHost.new(:hooked_browser_id => session_id, :ip => ip, :cid => cid)
            r.save
          end
        end
      end
    end

  end

  def self.options
    return [
        {'name' => 'ipRange', 'ui_label' => 'Scan IP range (C class)', 'value' => '192.168.0.1-192.168.0.254'},
        {'name' => 'ports',   'ui_label' => 'Ports', 'value' => '80,8080'},
        {'name' => 'threads', 'ui_label' => 'Workers', 'value' => '5'}
    ]
  end

end
