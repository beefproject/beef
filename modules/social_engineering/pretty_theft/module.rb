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
class Pretty_theft < BeEF::Core::Command
  
  def self.options
    configuration = BeEF::Core::Configuration.instance
    logo_uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/ui/media/images/beef.png"
    return [
		{'name' => 'choice', 'type' => 'combobox', 'ui_label' => 'Dialog Type', 'store_type' => 'arraystore', 'store_fields' => ['choice'], 'store_data' => [['Facebook'],['LinkedIn'],['Generic']], 'valueField' => 'choice', 'value' => 'Facebook', editable: false, 'displayField' => 'choice', 'mode' => 'local', 'autoWidth' => true },
       		
		{'name' => 'backing', 'type' => 'combobox', 'ui_label' => 'Backing', 'store_type' => 'arraystore', 'store_fields' => ['backing'], 'store_data' => [['Grey'],['Clear']], 'valueField' => 'backing', 'value' => 'Grey', editable: false, 'displayField' => 'backing', 'mode' => 'local', 'autoWidth' => true },

		{'name' =>'imgsauce', 'description' =>'Custom Logo', 'ui_label'=>'Custom Logo (Generic only)', 'value' => logo_uri}
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
