#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Mobilesafari_address_spoofing < BeEF::Core::Command

	def self.options
		return [
			{'name' => 'fake_url', 'ui_label' => 'Fake URL', 'type' => 'text', 'value' =>'http://en.wikipedia.org/wiki/Beef'},
			{'name' => 'real_url', 'ui_label' => 'Real URL', 'type' => 'text', 'value' => 'http://www.beefproject.com'},
			{'name' => 'domselectah', 'ui_label' => 'jQuery Selector for Link rewriting. \'a\' will overwrite all links', 'type' => 'text', 'value' => 'a'}
		]
	end

	def post_execute
		content = {}
		content['results'] = @datastore['results']
		content['query'] = @datastore['query']
		save content
	end

end

