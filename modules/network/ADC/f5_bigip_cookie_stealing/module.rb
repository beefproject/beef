#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class F5_bigip_cookie_stealing < BeEF::Core::Command

  def post_execute
    return if @datastore['result'].nil?
    save({'BigIPSessionCookies' => @datastore['BigIPSessionCookies']})
  end

end
