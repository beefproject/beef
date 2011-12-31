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
class Play_sound < BeEF::Core::Command
  
  # set and return all options for this module
  def self.options

    configuration = BeEF::Core::Configuration.instance

    sound_file_url = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/sound.wav"

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
