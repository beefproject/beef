#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Remove_stuck_iframes < BeEF::Core::Command

  def post_execute
    content = {}
    content['head'] = @datastore['head']
    content['body'] = @datastore['body']
    content['iframe_'] = @datastore['iframe_']
    save content
  end

end
