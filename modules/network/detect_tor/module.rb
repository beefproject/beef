#
# Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_tor < BeEF::Core::Command
  
  def self.options
    return [
        {'name'=>'timeout', 'ui_label' =>'Detection timeout','value'=>'10000'}
    ]
  end
  
  def post_execute
    return if @datastore['result'].nil?
    
    save({'result' => @datastore['result']})
  end
  
end
