#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Internal_network_fingerprinting < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'ipRange', 'ui_label' => 'Scan IP range (C class)', 'value' => '192.168.0.1-192.168.0.254'},
        {'name' => 'ports', 'ui_label' => 'Ports to test', 'value' => '80,8080'},
        {'name' => 'threads', 'ui_label' => 'Workers', 'value' => '5'},
        {'name' => 'wait', 'ui_label' => 'Wait (s) between each request for each worker', 'value' => '2'},
        {'name' => 'timeout', 'ui_label' => 'Timeout for each request (s)', 'value' => '10'}
    ]
  end
  
  def post_execute
    content = {}
    content['discovered'] = @datastore['discovered'] if not @datastore['discovered'].nil?
    content['url'] = @datastore['url'] if not @datastore['url'].nil?
    if content.empty?
      content['fail'] = 'No devices/applications have been discovered.'
    end
    save content

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true
      if @datastore['results'] =~ /^proto=(.+)&ip=(.+)&port=([\d]+)&discovered=(.+)&url=(.+)/
        proto = $1
        ip = $2
        port = $3
        discovered = $4
        url = $5
        session_id = @datastore['beefhook']
        cid = @datastore['cid'].to_i
        if BeEF::Filters.is_valid_ip?(ip)
          print_debug("Hooked browser found '#{discovered}' [ip: #{ip}]")
          BeEF::Core::Models::NetworkService.add(:hooked_browser_id => session_id, :proto => proto, :ip => ip, :port => port, :type => discovered, :cid => cid)
        end
      end

    end

  end
end
