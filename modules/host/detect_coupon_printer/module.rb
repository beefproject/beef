#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_coupon_printer < BeEF::Core::Command
  def post_execute
    save({'result' => @datastore['results']})
  end
end
