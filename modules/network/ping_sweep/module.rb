#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Ping_sweep < BeEF::Core::Command

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content

    configuration = BeEF::Core::Configuration.instance
    if configuration.get("beef.extension.network.enable") == true

      session_id = @datastore['beefhook']

      # log the network service
      if @datastore['results'] =~ /^ip=(.+)&ping=(\d+)ms$/
        ip = $1
        ping = $2
        if BeEF::Filters.is_valid_ip?(ip)
          print_debug("Hooked browser found host #{ip}")
          BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => session_id, :ip => ip)
        end
      end
    end

  end

  def self.options
    return [
        {'name' => 'rhosts', 'ui_label' => 'Scan IP range (C class)', 'value' => 'common' },
        {'name' => 'threads', 'ui_label' => 'Workers', 'value' => '3'}
    ]
  end

end
