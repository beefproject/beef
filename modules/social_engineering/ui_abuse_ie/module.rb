#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
################################################################################
# Based on the PoC by Rosario Valotta
# Ported to BeEF by antisnatchor
# For more information see: https://sites.google.com/site/tentacoloviola/
################################################################################
class Ui_abuse_ie < BeEF::Core::Command

	def self.options
		return [
        {'name' => 'dropper_url', 'ui_label' => 'Executable URL (must be signed)', 'value' => 'http://dropper_url/dropper.exe'}
		]
  end

  #TODO pre-execute -> read popunder.html, replace placeholder, and serve it mounting a new URL

	def post_execute
		content = {}
		content['results'] = @datastore['results']
		save content
	end

end

