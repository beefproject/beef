#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_local_storage < BeEF::Core::Command
  
  # More info:
  #   http://dev.w3.org/html5/webstorage/
  #   http://diveintohtml5.org/storage.html
  #
  
  def post_execute
    content = {}
    content['localStorage'] = @datastore['localStorage']
    save content
  end
  
end
