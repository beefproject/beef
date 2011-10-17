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
