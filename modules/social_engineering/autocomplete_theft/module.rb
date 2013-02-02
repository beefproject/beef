#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
################################################################################
# Based on the PoC by Stefano Di Paola
# Ported to BeEF by bcoles
# For more information see: http://blog.mindedsecurity.com/2011/10/autocompleteagain.html
################################################################################
class Steal_autocomplete < BeEF::Core::Command

	def self.options
		return [
			{	'name'         => 'input_name',
				'type'         => 'combobox',
				'ui_label'     => 'Input Field Name',
				'store_type'   => 'arraystore',
				'store_fields' => ['element_name'],
				'store_data'   => [
					['login'],
					['email'],
					['Email'],
					['session[username_or_email]'],
					['q'],
					['search'],
					['name'],
					['company'],
					['city'],
					['state'],
					['country'],
				],
				'emptyText'    => 'Select an input field name to steal autocomplete values',
				'valueField'   => 'element_name',
				'displayField' => 'element_name',
				'mode'         => 'local',
				'autoWidth'    => true
			}
		]
	end

	def post_execute
		content = {}
		content['results'] = @datastore['results']
		save content
	end

end

