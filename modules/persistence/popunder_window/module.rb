#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Popunder_window < BeEF::Core::Command
  def self.options
    [{ 'name' => 'clickjack',
       'ui_label' => 'Clickjack',
       'type' => 'checkbox',
       'checked' => false }]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
