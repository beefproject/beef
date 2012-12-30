#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Inter_protocol_irc < BeEF::Core::Command

  def self.options
    return [
	{'name' => 'rhost',   'ui_label' => 'IRC Server', 'value' => '127.0.0.1'},
	{'name' => 'rport',   'ui_label' => 'Port',       'value' => '6667'},
        {'name' => 'nick',    'ui_label' => 'Username',   'value' => 'user1234__'},
        {'name' => 'channel', 'ui_label' => 'Channel',    'value' => '#channel1'},
        {'name' => 'message', 'ui_label' => 'Message',    'value' => 'Message sent from the Browser Exploitation Framework!'}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end

end
