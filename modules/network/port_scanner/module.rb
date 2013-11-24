#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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
        {'name' => 'ports' , 'ui_label' => 'Specific port(s) to scan', 'value' => 'default'},
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
  end
end
