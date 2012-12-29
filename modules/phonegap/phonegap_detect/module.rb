#
# Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# phonegap
#

class Phonegap_detect < BeEF::Core::Command
  
  def post_execute
    content = {}
    content['phonegap'] = @datastore['phonegap']
    save content
  end
  
end
