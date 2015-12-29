#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_get_variable < BeEF::Core::Command

  def self.options
    return [{'name' => 'payload_name', 'ui_label'=>'Payload Name', 'type' => 'text', 'value' => 'message', 'width' => '400px'}]
  end

end
