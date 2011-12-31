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
class Get_registry_keys < BeEF::Core::Command

	def self.options
		return [
			{ 'name'=>'key_paths', 'ui_label' => 'Key(s)', 'description' => 'Enter registry keys. Note: each key requires its own line', 'type'=>'textarea', 'width' => '500px', 'height' => '350px', 'value'=>'HKLM\\SYSTEM\\CurrentControlSet\\Control\\SystemInformation\\SystemProductName
HKLM\\SYSTEM\\CurrentControlSet\\Control\\SystemInformation\\SystemManufacturer
HKLM\\SYSTEM\\CurrentControlSet\\Control\\SystemInformation\\BIOSVersion
HKLM\\SYSTEM\\CurrentControlSet\\Control\\SystemInformation\\BIOSReleaseDate
HKLM\\SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName\\ComputerName
HKLM\\SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ActiveComputerName\\ComputerName
HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\RegisteredOwner
HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\RegisteredOrganization
HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProductName
HKLM\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0\\ProcessorNameString
HKLM\\HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0\\Identifier'
}
		]
	end

	def post_execute
		content = {}
		content['result'] = @datastore['key_values'] if not @datastore['key_values'].nil?
		content['fail'] = 'No data was returned.' if content.empty?
		save content
	end
  
end

