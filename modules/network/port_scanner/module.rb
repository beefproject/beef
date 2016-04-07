#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#
# Port Scanner Module - javier.marcos
# Scan ports in a given hostname, using WebSockets CORS and HTTP with img tags. 
# It uses the three methods to avoid blocked ports or Same Origin Policy.


class Port_scanner < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'ipHost', 'ui_label' => 'Scan IP or Hostname', 'value' => '192.168.1.10'},
        {'name' => 'ports' , 'ui_label' => 'Specific port(s) to scan', 'value' => 'top'},
        {'name' => 'closetimeout' , 'ui_label' => 'Closed port timeout (ms)', 'value' => '1100'},
        {'name' => 'opentimeout', 'ui_label' => 'Open port timeout (ms)', 'value' => '2500'},
        {'name' => 'delay', 'ui_label' => 'Delay between requests (ms)', 'value' => '600'},
        {'name' => 'debug', 'ui_label' => 'Debug', 'value' => 'false'}
    ]
  end
  
  def post_execute
    content = {}
    content['port'] =@datastore['port'] if not @datastore['port'].nil?
    if content.empty?
      content['fail'] = 'No open ports have been found.'
    end
    save content

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true
      if @datastore['results'] =~ /^ip=([\d\.]+)&port=(CORS|WebSocket|HTTP): Port ([\d]+) is OPEN (.*)$/
        ip = $1
        port = $3
        service = $4
        session_id = @datastore['beefhook']
        proto = 'http'
        if BeEF::Filters.is_valid_ip?(ip)
          print_debug("Hooked browser found network service [ip: #{ip}, port: #{port}]")
          BeEF::Core::Models::NetworkService.add(:hooked_browser_id => session_id, :proto => proto, :ip => ip, :port => port, :type => service)
        end
      end

    end

  end
end
