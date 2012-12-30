#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Execute_tabs < BeEF::Core::Command

  def self.options
    return [
        {'name' => 'url', 'ui_label' => 'URL', 'value' => 'https://www.google.com/accounts/EditUserInfo',  'width' => '500px'},
        {'name' => 'theJS', 'ui_label' => 'Javascript', 'value' => 'prompt(\'BeEF\');', 'type' => 'textarea', 'width' => '400px', 'height' => '300px'}
    ]
  end

  def post_execute
    content = {}
    content['Return'] = @datastore['return']
    save content
  end
  
end

