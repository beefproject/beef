#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Replace_video < BeEF::Core::Command

  def self.options
    return [
        {'name' => 'youtube_id', 'ui_label' => 'YouTube Video ID', 'value' => 'XZ5TajZYW6Y', 'width'=>'150px'},
        {'name' => 'jquery_selector', 'ui_label' => 'jQuery Selector', 'value' => 'embed', 'width'=>'150px'}
    ]
  end

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content

  end

end
