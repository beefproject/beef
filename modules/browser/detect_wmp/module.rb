#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_wmp < BeEF::Core::Command

	def post_execute
		content = {}
		content['wmp'] = @datastore['wmp']
		save content
          if @datastore['results'] =~ /^wmp=(Yes|No)/
            bd = BeEF::Core::Models::BrowserDetails.set(@datastore['beefhook'], 'HasWMP', $1)
          end
	end

end
