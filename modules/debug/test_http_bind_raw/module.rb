#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_http_bind_raw < BeEF::Core::Command

  def pre_send
    configuration = BeEF::Core::Configuration.instance
    xss_hook_url = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/basic.html"
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_raw('200', {'Content-Type'=>'text/html','beef'=>xss_hook_url}, 'hello world!', '/beef', -1)
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end

end
