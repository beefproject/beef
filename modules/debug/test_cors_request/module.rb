#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_cors_request < BeEF::Core::Command

  def post_execute
    content = {}
    content['response'] = @datastore['response']
    save content
  end

  def self.options

    return [
        {'name' => 'method', 'ui_label' =>'Method', 'type' => 'text', 'width' => '400px', 'value' => 'GET' },
        {'name' => 'url',    'ui_label' =>'URL',    'type' => 'text', 'width' => '400px', 'value' => 'http://graph.facebook.com/fql?q=SELECT%20url,total_count%20FROM%20link_stat%20WHERE%20url=%27http://beefproject.com/%27' },
        {'name' => 'data',   'ui_label' =>'Data',   'type' => 'text', 'width' => '400px', 'value' => 'postdata' },
    ]
  end

end
