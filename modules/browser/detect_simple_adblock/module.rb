#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_simple_adblock< BeEF::Core::Command

	def post_execute 
		content = {}
		content['simple_adblock'] = @datastore['simple_adblock'] if not @datastore['simple_adblock'].nil?
		save content
	end

end
