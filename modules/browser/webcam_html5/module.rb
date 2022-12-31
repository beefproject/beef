#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'base64'
class Webcam_html5 < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'choice', 'type' => 'combobox', 'ui_label' => 'Screenshot size', 'store_type' => 'arraystore', 'store_fields' => ['choice'],
        'store_data' => [['320x240'], ['640x480'], ['Full']], 'valueField' => 'choice', 'value' => '320x240', editable: false, 'displayField' => 'choice', 'mode' => 'local', 'autoWidth' => true },
    ]
  end
  def post_execute
    content = {}
    content['result'] = @datastore['result'] unless @datastore['result'].nil?
    content['image'] = @datastore['image'] unless @datastore['image'].nil?
    save content
  end
end
