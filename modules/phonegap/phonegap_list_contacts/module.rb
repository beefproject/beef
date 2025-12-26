#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# // phonegap_list_contacts

class Phonegap_list_contacts < BeEF::Core::Command
  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end
end
