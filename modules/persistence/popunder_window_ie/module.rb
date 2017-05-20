#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Popunder_window_ie < BeEF::Core::Command
  def post_execute
    save({'result' => @datastore['result']})
  end
end
