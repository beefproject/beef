#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
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
    save({'result' => @datastore['result']})
  end
end
