#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Send_gvoice_sms < BeEF::Core::Command

  def self.options
    return [
        {'name' => 'to', 'ui_label' => 'To', 'value' => '1234567890',  'type' =>'textarea', 'width' => '300px'},
        {'name' => 'message', 'ui_label' => 'Message', 'value' => 'Hello from BeEF', 'type' => 'textarea', 'width' => '300px', 'height' => '200px'}
    ]
  end

  def post_execute
    content = {}
    content['To'] = @datastore['to']
    content['Message'] = @datastore['message']
    content['Status'] = @datastore['status']
    save content
  end
  
end
