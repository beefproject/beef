#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_notification < BeEF::Core::Command

  def self.options
    return [
      { 'name' => 'notification_text',
        'description' => 'Text displayed in the notification bar',
        'ui_label' => 'Text displayed in the notification bar',
        'value' => "This website wants to run the following applet: \\'Java\\' from \\'Microsoft Inc\\'. To continue using this website you must accept the following security popup"
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
