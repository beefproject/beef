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
class Inter_protocol_irc < BeEF::Core::Command

  def self.options
    return [
	{'name' => 'server', 'ui_label' => 'IRC Server', 'value' => '127.0.0.1'},
	{'name' => 'port', 'ui_label' => 'Port', 'value' => '6667'},
        {'name' => 'nick', 'ui_label' => 'Username', 'value' => 'user1234__'},
        {'name' => 'channel', 'ui_label' => 'Channel', 'value' => '#channel1'},
        {'name' => 'message', 'ui_label' => 'Message', 'value' => 'Message sent from the Browser Exploitation Framework!'}
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end

end
