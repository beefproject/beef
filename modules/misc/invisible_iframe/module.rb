#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Invisible_iframe < BeEF::Core::Command
  def self.options
    [
      { 'name' => 'target', 'ui_label' => 'URL', 'value' => 'http://beefproject.com/' }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
