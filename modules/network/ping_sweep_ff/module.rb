#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
#
# Ping Sweep Module - jgaliana
# Discover active hosts in the internal network of the hooked browser.
# It works calling a Java method from JavaScript and do not require user interaction.

class Ping_sweep_ff < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'ipRange', 'ui_label' => 'Scan IP range (C class or IP)', 'value' => '192.168.0.1-192.168.0.254' },
      { 'name' => 'timeout', 'ui_label' => 'Timeout (ms)', 'value' => '2000' },
      { 'name' => 'delay', 'ui_label' => 'Delay between requests (ms)', 'value' => '100' }
    ]
  end

  def post_execute
    content = {}
    content['host'] = @datastore['host'] unless @datastore['host'].nil?
    content['fail'] = 'No active hosts have been discovered.' if content.empty?
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true
    return unless @datastore['results'] =~ /host=([\d.]+) is alive/

    # save the network host
    ip = Regexp.last_match(1)
    session_id = @datastore['beefhook']
    if BeEF::Filters.is_valid_ip?(ip)
      print_debug("Hooked browser has network interface #{ip}")
      BeEF::Core::Models::NetworkHost.create(hooked_browser_id: session_id, ip: ip)
    end
  end
end
