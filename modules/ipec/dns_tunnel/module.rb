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
class Dns_tunnel < BeEF::Core::Command
  
  def self.options
	@configuration = BeEF::Core::Configuration.instance
	beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")

    return [
        {'name' => 'domain', 'ui_label'=>'Domain', 'type' => 'text', 'width' => '400px', 'value' => beef_host },
		{'name' => 'message', 'ui_label'=>'Message', 'type' => 'textarea', 'value' =>'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras rutrum fermentum nunc, vel varius libero pharetra a. Duis rhoncus nisi volutpat elit suscipit auctor. In fringilla est eget tortor bibendum gravida. Pellentesque aliquet augue libero, at gravida arcu. Nunc et quam sapien, eu pulvinar erat. Quisque dignissim imperdiet neque, et interdum sem sagittis a. Maecenas non mi elit, a luctus neque. Nam pulvinar libero sit amet dui suscipit facilisis. Duis sed mauris elit. Aliquam cursus scelerisque diam a fringilla. Curabitur mollis nisi in ante hendrerit pellentesque ut ac orci. In congue nunc vitae enim pharetra eleifend.', 'width' => '400px', 'height' => '300px'},
#        {'name' => 'wait', 'ui_label' => 'Wait between requests (ms)', 'value' => '1000', 'width'=>'100px' }
    ]
  end
  
  def post_execute
    content = {}
    content['dns_requests'] = @datastore['dns_requests']
    save content
  end
  
end
