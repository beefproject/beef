#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Test_return_ascii_chars < BeEF::Core::Command
  
  def post_execute
    content = {}
    content['Result String'] = @datastore['result_string']
    save content
  end

end
