#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Cross_origin_scanner_flash < BeEF::Core::Command
  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_cached('/modules/network/cross_origin_scanner_flash/ContentHijacking.swf', '/objects/ContentHijacking', 'swf')
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_cached('/modules/network/cross_origin_scanner_flash/swfobject.js', '/swfobject', 'js')
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true

    session_id = @datastore['beefhook']

    # log discovered hosts
    case @datastore['results']
    when /^ip=(.+)&status=alive$/
      ip = Regexp.last_match(1)
      if BeEF::Filters.is_valid_ip?(ip)
        print_debug("Hooked browser found host #{ip}")
        BeEF::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip)
      end
    # log discovered network services
    when /^proto=(.+)&ip=(.+)&port=(\d+)&title/
      proto = Regexp.last_match(1)
      ip = Regexp.last_match(2)
      port = Regexp.last_match(3)
      type = 'HTTP Server (Flash)'
      if BeEF::Filters.is_valid_ip?(ip)
        print_debug("Hooked browser found HTTP server #{ip}:#{port}")
        BeEF::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: proto, ip: ip, port: port, type: type)
      end
    end
  end

  def self.options
    [
      { 'name' => 'ipRange', 'ui_label' => 'Scan IP range (C class)', 'value' => '192.168.0.1-192.168.0.254' },
      { 'name' => 'ports',   'ui_label' => 'Ports', 'value' => '80,8080' },
      { 'name' => 'threads', 'ui_label' => 'Workers', 'value' => '2' },
      { 'name' => 'timeout', 'ui_label' => 'Timeout for each request (s)', 'value' => '5' }
    ]
  end
end
