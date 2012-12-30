#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_firebug < BeEF::Core::Command

	def post_execute 
		content = {}
		content['firebug'] = @datastore['firebug'] if not @datastore['firebug'].nil?
		save content
	end

end
