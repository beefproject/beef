#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Inter_protocol_redis < BeEF::Core::Command
  
  def self.options
    cmd = 'set server:name "BeEF says:\\\\nm00!"\\nquit\\n'
    return [
	{'name'=>'rhost',   'ui_label'=>'Target Address', 'value'=>'127.0.0.1'},
	{'name'=>'rport',   'ui_label'=>'Target Port',    'value'=>'6379'},
	{'name'=>'timeout', 'ui_label'=>'Timeout (s)',    'value'=>'15'},
	{'name'=>'commands','ui_label'=>'Redis commands', 'description'=>"Enter Redis commands to execute. Note: Use '\\n' to seperate Redis commands and '\\\\n' for new lines.", 'type'=>'textarea', 'value'=>cmd, 'width'=>'200px' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result'] if not @datastore['result'].nil?
    content['fail']   = @datastore['fail']   if not @datastore['fail'].nil?
    save content
  end
end
