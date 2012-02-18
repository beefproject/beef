# phonegap
#

class Phonegap_list_files < BeEF::Core::Command
  
    def self.options
        return [{
            'name' => 'directory', 
            'description' => 'List files in this directory', 
            'ui_label'=>'Directory', 
            'value' => '/',
            'width' => '300px'
            }]
  end

  def callback
    content = {}
    content['Result'] = @datastore['result']
    save content

  end 
end
