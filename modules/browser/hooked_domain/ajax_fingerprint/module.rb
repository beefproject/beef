#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Ajax_fingerprint < BeEF::Core::Command
 
  def post_execute
      content = {}
      content['script_urls'] = @datastore['script_urls'] if not @datastore['script_urls'].nil?
      if content.empty?
          content['fail'] = 'Failed to fingerprint ajax.'
      end
      save content
  end

end
