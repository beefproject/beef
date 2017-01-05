#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Play_sound < BeEF::Core::Command
  
  # set and return all options for this module
  def self.options

    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
    base_host = "#{proto}://#{beef_host}:#{beef_port}"

    sound_file_url = "#{base_host}/demos/sound.wav"

    return [{
      'name' => 'sound_file_uri', 
      'description' => 'The web accessible URI for the wave sound file.',
      'ui_label' => 'Sound File Path',
      'value' => sound_file_url,
      'width' => '300px' 
      }]
  end

  def post_execute     
    content = {}
    content['result'] = @datastore['result']          
    
    save content   
  end
  
end
