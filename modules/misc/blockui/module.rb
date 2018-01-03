#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Blockui < BeEF::Core::Command

  def self.options
    return [
        {'name' => 'message', 'ui_label' => 'Message', 'type' => 'textarea', 'value' => '<p>Please wait while your data is being saved...</p>', 'width' => '400px', 'height' => '100px' },
        {'name' => 'timeout', 'ui_label' => 'Timeout (s)', 'value' => '30', 'width' => '400px' }
    ]
  end
  
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end
  
end
