#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_form_values < BeEF::Core::Command

	def post_execute
		content = {}
		content['form_data'] = @datastore['form_data']
		save content
	end

end
