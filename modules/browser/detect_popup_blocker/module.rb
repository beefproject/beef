#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_popup_blocker < BeEF::Core::Command

  def post_execute
    content = {}
    content['popup_blocker_enabled'] = @datastore['popup_blocker_enabled']
    save content
  end
  
end
