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

