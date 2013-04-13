#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_tor < BeEF::Core::Command
  
  def self.options
    return [
    	{'name' => 'tor_resource', 'ui_label' => 'What Tor resource to request', 'value' => 'http://xycpusearchon2mc.onion/deeplogo.jpg'},
        {'name'=>'timeout', 'ui_label' =>'Detection timeout','value'=>'10000'}
    ]
  end
  
  def post_execute
    return if @datastore['result'].nil?
    
    save({'result' => @datastore['result']})
  end
  
end
