#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_coupon_printer < BeEF::Core::Command
  def post_execute
    save({ 'result' => @datastore['results'] })
  end
end
