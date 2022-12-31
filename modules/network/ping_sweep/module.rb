#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Ping_sweep < BeEF::Core::Command
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true

    # log the network service
    return unless @datastore['results'] =~ /^ip=(.+)&ping=(\d+)ms$/

    ip = Regexp.last_match(1)
    # ping = Regexp.last_match(2)
    session_id = @datastore['beefhook']
    if BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser found host #{ip}")
      BeEF::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip)
    end
  end

  def self.options
    [
      { 'name' => 'rhosts', 'ui_label' => 'Scan IP range (C class)', 'value' => 'common' },
      { 'name' => 'threads', 'ui_label' => 'Workers', 'value' => '3' }
    ]
  end
end
