#
# Copyright (c) 2006-2021 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap persistenece
#

class Phonegap_persistence < BeEF::Core::Command

  def self.options

    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.beef_proto
    beef_host = @configuration.beef_host
    beef_port = @configuration.beef_port
    hook_file = @configuration.hook_file_path

    return [{
      'name' => 'hook_url',
      'description' => 'The URL of your BeEF hook',
      'ui_label'=>'Hook URL',
      'value' => proto + '://'+beef_host+':'+beef_port+hook_file,
      'width' => '300px'
    }]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
