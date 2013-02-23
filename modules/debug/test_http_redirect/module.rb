#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_http_redirect < BeEF::Core::Command

  def pre_send
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_redirect('http://beefproject.com', '/redirect')
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end

end
