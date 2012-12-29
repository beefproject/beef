#
# Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Grab_google_contacts < BeEF::Core::Command

  def post_execute
    content = {}
    content['Return'] = @datastore['return']
    save content
  end
  
end
