#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_unsafe_activex < BeEF::Core::Command

	def post_execute
		content = {}
		content['unsafe_activex'] = @datastore['unsafe_activex']
		save content
	end

end
