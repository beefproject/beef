#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_notification_c < BeEF::Core::Command

  def self.options
    return [
      {'name' => 'url', 'ui_label' => 'URL', 'value' => 'http://the.earth.li/~sgtatham/putty/latest/x86/putty.exe', 'width'=>'150px'},
      { 'name' => 'notification_text',
        'description' => 'Text displayed in the notification bar',
        'ui_label' => 'Notification text',
        'value' => "Additional plugins are required to display all the media on this page."
      }
    ]
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end
  
end
