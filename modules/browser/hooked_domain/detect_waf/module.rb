#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_waf < BeEF::Core::Command

  def self.options
    configuration = BeEF::Core::Configuration.instance
    proto = configuration.get("beef.http.https.enable") == true ? "https" : "http"
    waf_url = "#{proto}://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/waf"
    return [
      { 'name' => 'targetUrl', 'ui_label' => 'Target URL', 'value' => 'http://testmywaf.com', 'width' => '200px' },
      { 'name' => 'handlerUrl', 'ui_label' => 'Handler URL', 'value' => waf_url, 'width'=>'200px' }
    ]
  end
	
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end

end
