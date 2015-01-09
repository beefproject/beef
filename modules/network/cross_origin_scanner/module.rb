#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Cross_origin_scanner < BeEF::Core::Command

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end

  def self.options
    return [
        {'name' => 'ipRange', 'ui_label' => 'Scan IP range (C class)', 'value' => '192.168.0.1-192.168.0.254'},
        {'name' => 'threads', 'ui_label' => 'Workers', 'value' => '5'}
    ]
  end

end
