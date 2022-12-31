#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Get_http_servers < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'rhosts', 'ui_label' => 'Remote IP(s)', 'value' => 'common' },
      { 'name' => 'ports', 'ui_label' => 'Ports', 'value' => '80,8080' },
      { 'name' => 'threads', 'ui_label' => 'Workers', 'value' => '3' },
      { 'name' => 'wait', 'ui_label' => 'Wait (s) between each request for each worker', 'value' => '5' },
      { 'name' => 'timeout', 'ui_label' => 'Timeout for each request (s)', 'value' => '10' }
    ]
  end

  def post_execute
    content = {}
    content['url'] = @datastore['url'] unless @datastore['url'].nil?
    content['fail'] = 'No HTTP servers were discovered.' if content.empty?
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true
    return unless @datastore['results'] =~ /^proto=(.+)&ip=(.+)&port=(\d+)&url=(.+)/

    proto = Regexp.last_match(1)
    ip = Regexp.last_match(2)
    port = Regexp.last_match(3)
    url = Regexp.last_match(4)
    session_id = @datastore['beefhook']
    if !ip.nil? && BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found HTTP Server [proto: #{proto}, ip: #{ip}, port: #{port}]")
      BeEF::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: proto, ip: ip, port: port, type: 'HTTP Server')
    end
  end
end
