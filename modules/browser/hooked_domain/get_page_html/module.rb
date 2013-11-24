#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_page_html < BeEF::Core::Command

  def post_execute
    content = {}
    content['head'] = @datastore['head']
    content['body'] = @datastore['body']
    save content
  end

end
