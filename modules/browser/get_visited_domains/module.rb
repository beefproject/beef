#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Get_visited_domains < BeEF::Core::Command

  def self.options
    return [{
      'name' => 'domains', 
      'description' => 'Specify additional resources to fetch during visited domains analysis. Paste to the below field full URLs leading to CSS, image, JS or other *static* resources hosted on desired page. Separate domain names with url by using semicolon (;). Next domains separate by comma (,).', 
      'type' => 'textarea',
      'ui_label' => 'Specify custom page to check',
      'value' => 'Redtube ; http://images.cdn.redtube.com/_thumbs/v2009/favicon.ico,',
      'width' => '400px',
      'height' => '200px'
    }]
  end

  def post_execute
    content = {}
    content['results'] = @datastore['results']
    save content
  end

end
