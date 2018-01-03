#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_office < BeEF::Core::Command

	def post_execute
		content = {}
		content['office'] = @datastore['office']
		save content
          if @datastore['results'] =~ /^office=Office (\d+|Xp)/
            bd = BeEF::Core::Models::BrowserDetails.set(@datastore['beefhook'], 'HasOffice', $1)
          end
	end

end
