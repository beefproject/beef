#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Site_redirect < BeEF::Core::Command
  
  def self.options
    return [
        { 'ui_label'=>'Redirect URL', 'name'=>'redirect_url', 'description' => 'The URL the target will be redirected to.', 'value'=>'http://beefproject.com/', 'width'=>'200px' }
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
