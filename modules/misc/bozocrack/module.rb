#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Bozo_crack < BeEF::Core::Command

	def self.options
		return [
			{'name' => 'hash', 'ui_label' => 'MD5 Hash', 'value' => '5f4dcc3b5aa765d61d8327deb882cf99' }
		]
	end

	def post_execute
		content = {}
		content['result'] = @datastore['result'] if not @datastore['result'].nil?
		content['fail']   = @datastore['fail']   if not @datastore['fail'].nil?
		save content
	end

end

