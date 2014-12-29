#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_lastpass < BeEF::Core::Command

	def post_execute 
		content = {}
		content['lastpass'] = @datastore['lastpass'] if not @datastore['lastpass'].nil?
		save content
	end

end
