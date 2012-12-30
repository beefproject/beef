#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Tabnabbing < BeEF::Core::Command
  
	def self.options
		configuration = BeEF::Core::Configuration.instance
		uri = "http://#{configuration.get("beef.http.host")}:#{configuration.get("beef.http.port")}/demos/basic.html"
		return [
			{ 'name' => 'url', 'description' => 'Redirect URL', 'ui_label' => 'URL', 'value' => uri, 'width'=>'400px' },
			{ 'name' => 'wait', 'description' => 'Wait (minutes)', 'ui_label' => 'Wait (minutes)', 'value' => '15', 'width'=>'150px' }
		]
	end

	def post_execute
		content = {}
		content['tabnab'] = @datastore['tabnab']
		save content
	end
  
end
