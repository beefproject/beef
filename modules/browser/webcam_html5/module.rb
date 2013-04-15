#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'base64'
class Webcam_html5 < BeEF::Core::Command
  
	def post_execute 
		content = {}
		content["result"] = @datastore["result"] if not @datastore["result"].nil?
    content["image"] = @datastore["image"] if not @datastore["image"].nil?
		save content
	end

end
