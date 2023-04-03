#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Replace_video_fake_plugin < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'url', 'ui_label' => 'Payload URL', 'value' => '', 'width' => '150px' },
      { 'name' => 'jquery_selector', 'ui_label' => 'jQuery Selector', 'value' => 'embed', 'width' => '150px' }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
