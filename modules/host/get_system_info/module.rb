#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_system_info < BeEF::Core::Command
  
	def pre_send
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/host/get_system_info/getSystemInfo.class','/getSystemInfo','class')
	end
  
	def post_execute
		content = {}
		content['result'] = @datastore['system_info'] if not @datastore['system_info'].nil?
		content['fail'] = 'No data was returned.' if content.empty?
		save content
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/getSystemInfo.class')
	end
  
end

