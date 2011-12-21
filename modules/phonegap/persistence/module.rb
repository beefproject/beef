# phonegap persistenece
#

class Persistence < BeEF::Core::Command

 def self.options
        return [{
            'name' => 'hook_url',
            'description' => 'The URL of your beef hook',
            'ui_label'=>'Hook URL',
            'value' => 'http://beef:3000/hook.js',
            'width' => '300px'
            }]
  end

   def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
