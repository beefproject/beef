#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_get_variable < BeEF::Core::Command
  def self.options
    [{ 'name' => 'payload_name', 'ui_label' => 'Payload Name', 'type' => 'text', 'value' => 'message', 'width' => '400px' }]
  end
end
