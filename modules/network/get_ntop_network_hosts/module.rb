#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_ntop_network_hosts < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'rhost', 'ui_label' => 'Remote Host', 'value' => '127.0.0.1' },
      { 'name' => 'rport', 'ui_label' => 'Remote Port', 'value' => '3000' }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true
    return unless @datastore['results'] =~ /^proto=(https?)&ip=([\d.]+)&port=(\d+)&data=(.+)\z/

    proto = Regexp.last_match(1)
    ip = Regexp.last_match(2)
    port = Regexp.last_match(3)
    data = Regexp.last_match(4)
    session_id = @datastore['beefhook']
    type = 'ntop'
    if BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found 'ntop' [proto: #{proto}, ip: #{ip}, port: #{port}]")
      BeEF::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: proto, ip: ip, port: port, type: type)
    end
    data.to_s.scan(/"hostNumIpAddress":"([\d.]+)"/).flatten.each do |ip|
      if BeEF::Filters.is_valid_ip?(ip)
        print_debug("Hooked browser found host #{ip}")
        BeEF::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip, port: port)
      end
    end
  end
end
