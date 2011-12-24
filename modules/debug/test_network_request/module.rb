#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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
class Test_network_request < BeEF::Core::Command

  def post_execute
    content = {}
    content['response'] = @datastore['response']
    save content
  end

  def self.options
    @configuration = BeEF::Core::Configuration.instance
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.port")

    return [
        {'name' => 'scheme', 'ui_label'=>'Scheme', 'type' => 'text', 'width' => '400px', 'value' => 'http' },
        {'name' => 'method', 'ui_label'=>'Method', 'type' => 'text', 'width' => '400px', 'value' => 'GET' },
        {'name' => 'domain', 'ui_label'=>'Domain', 'type' => 'text', 'width' => '400px', 'value' => beef_host },
        {'name' => 'port', 'ui_label'=>'Port', 'type' => 'text', 'width' => '400px', 'value' => beef_port },
        {'name' => 'path', 'ui_label'=>'Path', 'type' => 'text', 'width' => '400px', 'value' => '/demos/secret_page.html' },
        {'name' => 'anchor', 'ui_label'=>'Anchor', 'type' => 'text', 'width' => '400px', 'value' => 'irrelevant' },
        {'name' => 'data', 'ui_label'=>'Query String', 'type' => 'text', 'width' => '400px', 'value' => 'query=data' },
        {'name' => 'timeout', 'ui_label' => 'Timeout (s)', 'value' => '10', 'width'=>'400px' },
        {'name' => 'dataType', 'ui_label'=>'Data Type', 'type' => 'text', 'width' => '400px', 'value' => 'script' },
    ]
  end

end
