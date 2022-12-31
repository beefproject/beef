#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_foxit < BeEF::Core::Command
  def post_execute
    content = {}
    content['foxit'] = @datastore['foxit']
    save content
    BeEF::Core::Models::BrowserDetails.set(@datastore['beefhook'], 'HasFoxit', Regexp.last_match(1)) if @datastore['results'] =~ /^foxit=(Yes|No)/
  end
end
