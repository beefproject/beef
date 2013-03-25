#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Link_rewrite_click_events < BeEF::Core::Command
  
  def self.options
    return [
        { 'ui_label'=>'URL', 'name'=>'url', 'description' => 'Target URL', 'value'=>'http://beefproject.com/', 'width'=>'200px' }
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
