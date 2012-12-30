#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Inter_protocol_imap < BeEF::Core::Command

  def self.options
    return [
	{'name' => 'server', 'ui_label' => 'IMAP Server', 'value' => '127.0.0.1'},
	{'name' => 'port', 'ui_label' => 'Port', 'value' => '220'},
        {'name' => 'commands', 'ui_label' => 'Commands', 'type'  => 'textarea', 'value' => 'a01 login root password\na002 logout'}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end

end
