#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_page_html_iframe < BeEF::Core::Command

  def post_execute
    content = {}
    content['head'] = @datastore['head']
    content['body'] = @datastore['body']
    content['iframe_'] = @datastore['iframe_']
    save content
  end

end
