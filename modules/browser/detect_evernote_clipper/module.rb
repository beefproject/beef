#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_evernote_clipper < BeEF::Core::Command

	def post_execute 
		content = {}
		content['evernote_clipper'] = @datastore['evernote_clipper'] if not @datastore['evernote_clipper'].nil?
		save content
	end

end
