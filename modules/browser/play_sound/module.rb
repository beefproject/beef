#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Play_sound < BeEF::Core::Command
  def self.options
    [{
      'name' => 'sound_file_uri',
      'description' => 'The web accessible URI for the wave sound file.',
      'ui_label' => 'Sound File Path',
      'value' => '',
      'width' => '300px'
    }]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']

    save content
  end
end
