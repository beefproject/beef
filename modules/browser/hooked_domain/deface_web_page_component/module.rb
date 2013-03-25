#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Deface_web_page_component < BeEF::Core::Command

  def self.options
    return [
		{ 'name' => 'deface_selector', 'description' => 'The jQuery Selector to rewrite', 'ui_label' => 'Target Selector (Using jQuery\'s selector notation)', 'value' => '.headertitle', 'width'=>'200px' },
		{ 'name' => 'deface_content', 'description' => 'The HTML to replace within the target', 'ui_label' => 'Deface Content', 'value' => 'BeEF was ere', 'width'=>'200px' }
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end
