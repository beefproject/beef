#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fetch_port_scanner < BeEF::Core::Command
  # set and return all options for this module
  def self.options
    [
      { 'name' => 'ipHost', 'ui_label' => 'Scan IP or Hostname', 'value' => '127.0.0.1' },
      { 'name' => 'ports', 'ui_label' => 'Specific port(s) to scan', 'value' => 'top' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    configuration = BeEF::Core::Configuration.instance
    return unless configuration.get('beef.extension.network.enable') == true

    session_id = @datastore['beefhook']

    # @todo log the network service
    # will need to once the datastore is confirmed.
    # This should basically try and hook the browser
  end
end
