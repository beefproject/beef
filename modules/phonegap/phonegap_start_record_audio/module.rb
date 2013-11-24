#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap
#

class Phonegap_start_record_audio < BeEF::Core::Command
    
  def self.options
    return [
        {'name' => 'file_name', 
         'description' => 'File name for audio recording', 
         'ui_label' => 'File Name',
         'value' => 'myrecording.wav'
         } 
    ]
  end    
  
  def post_execute
    content = {}
    content['file_name'] = @datastore['file_name']
    save content
  end
  
end
