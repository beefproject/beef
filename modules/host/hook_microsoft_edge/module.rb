#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Hook_microsoft_edge < BeEF::Core::Command
  def self.options
    @configuration = BeEF::Core::Configuration.instance
    proto = @configuration.get("beef.http.https.enable") == true ? "https" : "http"
    beef_host = @configuration.get("beef.http.public") || @configuration.get("beef.http.host")
    beef_port = @configuration.get("beef.http.public_port") || @configuration.get("beef.http.port")
    hook_uri = "#{proto}://#{beef_host}:#{beef_port}/demos/plain.html"

    return [
      {'name' => 'url', 'ui_label'=>'URL', 'type' => 'text', 'width' => '400px', 'value' => hook_uri },
    ]
  end 

  def post_execute
    content = {}
    content['result'] = @datastore['result']          
    save content
  end
end
