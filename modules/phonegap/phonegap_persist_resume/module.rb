#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

#   persist on over app's sleep/wake events
class Phonegap_persist_resume < BeEF::Core::Command

   def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end 
  
end
