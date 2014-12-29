#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_office < BeEF::Core::Command

	def post_execute
		content = {}
		content['office'] = @datastore['office']
		save content
	end

end
