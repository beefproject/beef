#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_activex < BeEF::Core::Command

	def post_execute
		content = {}
		content['activex'] = @datastore['activex']
		save content
          if @datastore['results'] =~ /^activex=(Yes|No)/
            bd = BeEF::Core::Models::BrowserDetails.set(@datastore['beefhook'], 'HasActiveX', $1)
          end
	end

end
