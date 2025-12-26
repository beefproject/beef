#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Link_rewrite_click_events < BeEF::Core::Command
  def self.options
    [
      { 'ui_label' => 'URL', 'name' => 'url', 'description' => 'Target URL', 'value' => 'https://beefproject.com/', 'width' => '200px' }
    ]
  end

  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
