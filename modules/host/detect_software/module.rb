#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_software < BeEF::Core::Command
  
  def post_execute
    content = {}
    content['detect_software'] = @datastore['detect_software']
    save content
  end
  
end
