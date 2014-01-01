#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_bitdefender2012 < BeEF::Core::Command

  def post_execute
    save({'BitDefender' => @datastore['bitdefender']})
  end

end
