#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_google_desktop < BeEF::Core::Command
  
  def post_execute
    save({'GoogleDesktop' => @datastore['google_desktop']})
  end
  
end
