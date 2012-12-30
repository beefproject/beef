#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Google_search < BeEF::Core::Command

	def self.options
		return [
			{'name' => 'query', 'ui_label' => 'Query', 'type' => 'textarea', 'value' =>'beef', 'width' => '400px', 'height' => '50px'}
		]
	end

	def post_execute
		content = {}
		content['results'] = @datastore['results']
		content['query'] = @datastore['query']
		save content
	end

end

