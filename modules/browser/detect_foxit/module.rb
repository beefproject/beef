#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_foxit < BeEF::Core::Command

	def post_execute
		content = {}
		content['foxit'] = @datastore['foxit']
		save content
          if @datastore['results'] =~ /^foxit=(Yes|No)/
            bd = BeEF::Core::Models::BrowserDetails.set(@datastore['beefhook'], 'HasFoxit', $1)
          end
	end

end
