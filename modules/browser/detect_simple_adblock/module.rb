#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_simple_adblock < BeEF::Core::Command
  def post_execute
    content = {}
    content['simple_adblock'] = @datastore['simple_adblock'] unless @datastore['simple_adblock'].nil?
    save content
  end
end
