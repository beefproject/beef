#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Hook_microsoft_edge < BeEF::Core::Command
  def self.options
    configuration = BeEF::Core::Configuration.instance
    hook_uri = "#{configuration.beef_url_str}/demos/plain.html"

    [
      { 'name' => 'url', 'ui_label' => 'URL', 'type' => 'text', 'width' => '400px', 'value' => hook_uri }
    ]
  end

  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end
end
