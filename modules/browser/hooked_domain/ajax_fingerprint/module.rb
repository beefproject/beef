#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Ajax_fingerprint < BeEF::Core::Command
  def post_execute
    content = {}
    content['script_urls'] = @datastore['script_urls'] unless @datastore['script_urls'].nil?
    content['fail'] = 'Failed to fingerprint ajax.' if content.empty?
    save content
  end
end
