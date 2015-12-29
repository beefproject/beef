#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Get_visited_domains < BeEF::Core::Command

  def post_execute
    content = {}
    content['results'] = @datastore['results']
    save content
  end

end
