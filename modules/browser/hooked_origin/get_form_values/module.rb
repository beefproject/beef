#
# Copyright (c) 2006-2025 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_form_values < BeEF::Core::Command
  def post_execute
    content = {}
    content['result'] = @datastore['result']
    save content
  end
end
