#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Iframe_above < BeEF::Core::Command
  # This method is being called when a hooked browser sends some
  # data back to the framework.
  #
  def post_execute
    save({ 'result' => @datastore['result'] })
  end
end
