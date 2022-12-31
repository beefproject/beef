#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_cups < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'ipHost', 'ui_label' => 'IP or Hostname', 'value' => '127.0.0.1' },
      { 'name' => 'port', 'ui_label' => 'Port', 'value' => '631' }
    ]
  end

  def post_execute
    save({ 'CUPS' => @datastore['cups'] })

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true
    return unless @datastore['results'] =~ /^proto=(https?)&ip=([\d.]+)&port=(\d+)&cups=Installed$/

    proto = Regexp.last_match(1)
    ip = Regexp.last_match(2)
    port = Regexp.last_match(3)
    session_id = @datastore['beefhook']
    type = 'CUPS'
    if BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found 'CUPS' [proto: #{proto}, ip: #{ip}, port: #{port}]")
      BeEF::Core::Models::NetworkService.create(hooked_browser_id: session_id, proto: proto, ip: ip, port: port, type: type)
    end
  end
end
