#
# Copyright (c) 2006-2012 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Confirm_close_tab < BeEF::Core::Command

  	def post_execute
    		save({'result' => @datastore['result']})
  	end
  
end
