#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap persistenece
#

class Phonegap_persistence < BeEF::Core::Command

  def self.options

    @configuration = BeEF::Core::Configuration.instance
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")

    return [{
      'name' => 'hook_url',
      'description' => 'The URL of your BeEF hook',
      'ui_label'=>'Hook URL',
      'value' => 'http://'+beef_host+':'+beef_port+'/hook.js',
      'width' => '300px'
    }]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
