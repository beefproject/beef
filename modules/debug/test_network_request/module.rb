#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_network_request < BeEF::Core::Command
  def post_execute
    content = {}
    content['response'] = @datastore['response']
    save content
  end

  def self.options
    @configuration = BeEF::Core::Configuration.instance
    beef_host = @configuration.beef_host
    beef_port = @configuration.beef_port
    hook_path = @configuration.get('beef.http.hook_file')

    [
      { 'name' => 'scheme', 'ui_label' => 'Scheme', 'type' => 'text', 'width' => '400px', 'value' => 'http' },
      { 'name' => 'method', 'ui_label' => 'Method', 'type' => 'text', 'width' => '400px', 'value' => 'GET' },
      { 'name' => 'domain', 'ui_label' => 'Domain', 'type' => 'text', 'width' => '400px', 'value' => beef_host },
      { 'name' => 'port', 'ui_label' => 'Port', 'type' => 'text', 'width' => '400px', 'value' => beef_port },
      { 'name' => 'path', 'ui_label' => 'Path', 'type' => 'text', 'width' => '400px', 'value' => hook_path },
      { 'name' => 'anchor', 'ui_label' => 'Anchor', 'type' => 'text', 'width' => '400px', 'value' => 'irrelevant' },
      { 'name' => 'data', 'ui_label' => 'Query String', 'type' => 'text', 'width' => '400px', 'value' => 'query=data' },
      { 'name' => 'timeout', 'ui_label' => 'Timeout (s)', 'value' => '10', 'width' => '400px' },
      { 'name' => 'dataType', 'ui_label' => 'Data Type', 'type' => 'text', 'width' => '400px', 'value' => 'script' }
    ]
  end
end
