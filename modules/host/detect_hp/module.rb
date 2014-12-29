#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
##
class Detect_hp < BeEF::Core::Command

  def post_execute
    content = {}
    content['is_hp'] = @datastore['is_hp'] if not @datastore['is_hp'].nil?
    save content
  end

end
