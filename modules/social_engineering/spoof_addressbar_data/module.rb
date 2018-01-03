#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Spoof_addressbar_data < BeEF::Core::Command

  def self.options
    [
      {'name' => 'spoofed_url', 'ui_label' => 'Spoofed URL', 'type' => 'text', 'value' => 'https://example.com/'},
      {'name' => 'real_url', 'ui_label' => 'Real URL', 'type' => 'text', 'value' => 'https://example.com/'}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end
end
