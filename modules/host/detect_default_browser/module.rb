#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_default_browser < BeEF::Core::Command
  def post_execute
    content = {}
    content['browser'] = @datastore['browser'] unless @datastore['browser'].nil?
    save content
  end
end
