#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Internal_network_fingerprinting < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'ipRange', 'ui_label' => 'Scan IP range (C class)', 'value' => '192.168.0.1-192.168.0.254' },
      { 'name' => 'ports', 'ui_label' => 'Ports to test', 'value' => '80,8080' },
      { 'name' => 'threads', 'ui_label' => 'Workers', 'value' => '3' },
      { 'name' => 'wait', 'ui_label' => 'Wait (s) between each request for each worker', 'value' => '5' },
      { 'name' => 'timeout', 'ui_label' => 'Timeout for each request (s)', 'value' => '10' }
    ]
  end

  def post_execute
    content = {}
    content['discovered'] = @datastore['discovered'] unless @datastore['discovered'].nil?
    content['url'] = @datastore['url'] unless @datastore['url'].nil?
    content['fail'] = 'No devices/applications have been discovered.' if content.empty?
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true && (@datastore['results'] =~ /^proto=(.+)&ip=(.+)&port=(\d+)&discovered=(.+)&url=(.+)/)

    proto = Regexp.last_match(1)
    ip = Regexp.last_match(2)
    port = Regexp.last_match(3)
    discovered = Regexp.last_match(4)
    url = Regexp.last_match(5)
    session_id = @datastore['beefhook']
    if BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found '#{discovered}' [ip: #{ip}]")
      BeEF::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: proto, ip: ip, port: port, type: discovered)
    end
  end
end
