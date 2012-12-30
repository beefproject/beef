#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_soc_nets < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'timeout', 'ui_label' => 'Detection Timeout','value' => '5000'}
    ]
  end
  
  def post_execute
    content = {}
    content['GMail'] = @datastore['gmail']
    content['Facebook'] = @datastore['facebook']
    content['Twitter']= @datastore['twitter']
    save content
  end
  
end
