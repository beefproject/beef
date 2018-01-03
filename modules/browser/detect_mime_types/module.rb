#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_mime_types < BeEF::Core::Command
  def post_execute
    content = {}
    content['mime_types'] = @datastore['mime_types'] unless @datastore['mime_types'].nil?
    save content
  end
end
