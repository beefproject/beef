#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Confirm_close_tab < BeEF::Core::Command

	def self.options
		return [{
			'name' => 'text', 
			'description' => 'Specifies message to display to the user.', 
			'type' => 'textarea',
			'ui_label' => 'Confirm text',
			'value' => 'Are you sure you want to navigate away from this page?\n\n There is currently a request to the server pending. You will lose recent changes by navigating away.\n\n Press OK to continue, or Cancel to stay on the current page.',
			'width' => '400px' 
		},
		{	'name' => 'usePopUnder', 
			'type' => 'checkbox', 
			'ui_label' => 'Create a pop-under window on user\'s tab closing', 
			'checked' => 'true'
		}]
	end
	
  	def post_execute
    		save({'result' => @datastore['result']})
  	end
  
end
