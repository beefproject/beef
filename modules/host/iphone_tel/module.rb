#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Iphone_tel < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'tel_num', 'description' => 'Telephone number', 'ui_label' => 'Number', 'value' => '5551234', 'width' => '200px' }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
