#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# More info:
#	http://blog.kotowicz.net/2012/02/intro-to-chrome-addons-hacking.html
#
class Detect_chrome_extensions < BeEF::Core::Command

  def post_execute
    content = {}
    content['extension'] = @datastore['extension']
    save content
  end
  
end

