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
