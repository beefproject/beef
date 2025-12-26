#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class F5_bigip_cookie_stealing < BeEF::Core::Command
  def post_execute
    return if @datastore['result'].nil?

    save({ 'BigIPSessionCookies' => @datastore['BigIPSessionCookies'] })
  end
end
