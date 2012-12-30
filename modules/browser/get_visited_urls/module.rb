#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_visited_urls < BeEF::Core::Command
  
  def self.options
    return [
        { 'ui_label'=>'URL(s)', 
          'name'=>'urls', 
          'description' => 'Enter target URL(s)', 
          'type'=>'textarea', 
          'value'=>'http://beefproject.com/', 
          'width'=>'200px' }
    ]
  end

  def post_execute
    save({'result' => @datastore['result']})
  end
  
end
