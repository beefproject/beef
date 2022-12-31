#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#
# Port Scanner Module - javier.marcos
# Scan ports in a given hostname, using WebSockets CORS and HTTP with img tags.
# It uses the three methods to avoid blocked ports or Same Origin Policy.

class Port_scanner < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'ipHost', 'ui_label' => 'Scan IP or Hostname', 'value' => '192.168.1.10' },
      { 'name' => 'ports', 'ui_label' => 'Specific port(s) to scan', 'value' => 'top' },
      { 'name' => 'closetimeout', 'ui_label' => 'Closed port timeout (ms)', 'value' => '1100' },
      { 'name' => 'opentimeout', 'ui_label' => 'Open port timeout (ms)', 'value' => '2500' },
      { 'name' => 'delay', 'ui_label' => 'Delay between requests (ms)', 'value' => '600' },
      { 'name' => 'debug', 'ui_label' => 'Debug', 'value' => 'false' }
    ]
  end

  def post_execute
    content = {}
    content['port'] = @datastore['port'] unless @datastore['port'].nil?
    content['fail'] = 'No open ports have been found.' if content.empty?
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true
    return unless @datastore['results'] =~ /^ip=([\d.]+)&port=(CORS|WebSocket|HTTP): Port (\d+) is OPEN (.*)$/

    ip = Regexp.last_match(1)
    port = Regexp.last_match(3)
    service = Regexp.last_match(4)
    session_id = @datastore['beefhook']
    proto = 'http'
    if BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found network service [ip: #{ip}, port: #{port}]")
      BeEF::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: proto, ip: ip, port: port, ntype: service)
    end
  end
end
