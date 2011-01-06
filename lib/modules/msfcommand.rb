module BeEF
module Modules
module Commands


class Msf < BeEF::Command

  
  def initialize
    super({
      'Name' => 'Generic Metasploit Exploit',

      'Description' => %Q{
        This module will launch a Metasploit exploit against the host
        },
      'Category' => 'Metasploit',
      'Author' => ['sussurro'],
      'Data' => [ ], 
      'File' => __FILE__,
    })
    
    use 'beef.dom'
    use_template!
  end
  
  def callback
                save({'result' => @datastore['result']})
  end

	def update_info(id)
				mod = BeEF::Models::CommandModule.first(:id => id)
				msfinfo = nil
        targets = []

				if mod.dynamic_command_info == nil
					msf = BeEF::MsfClient.new
					msf.login()
					msfinfo = msf.get_exploit_info(mod.name)

				  st = mod.name.split('/').first

					os_name = BeEF::Constants::Os::match_os(st)
					browsers =  BeEF::Constants::Browsers::match_browser(msfi['name'] + msfi['targets'].to_json)

					targets << {'os_name' => os_name, 'browser_name' => 'ALL'} if browsers.count == 0

					browsers.each do |bn|
						targets << {'os_name' => os_name, 'browser_name' => bn}
					end


				  mod.dynamic_command_info = BeEF::Models::DynamicCommandInfo.new( 
																				 :name => msfinfo['name'],
																				 :description => msfinfo['description'],
																				 :targets => targets.to_json);
					mod.save
				else
					msfinfo = mod.dynamic_command_info
					targets = JSON.parse(msfinfo['targets'])
				end
				@info['Name'] = msfinfo['name']
				@info['Description'] = msfinfo['description']
				@info['MsfModName'] = mod.name
				@target = targets


	end
	def update_data()
				modname = @info['MsfModName']

				msf = BeEF::MsfClient.new
				msf.login()

				msfoptions = msf.get_options(modname)
			  msfoptions.keys.each { |k|
								next if msfoptions[k]['advanced'] == true
								next if msfoptions[k]['evasion'] == true
							  @info['Data'] << [ 'name' => k + '_txt', 'type' => 'label', 'html' => msfoptions[k]['desc']]
							  case msfoptions[k]['type']
							  when "string","address","port"
									@info['Data'] << ['name' => k , 'ui_label' => k, 'value' => msfoptions[k]['default']]
								when "bool"
									@info['Data'] <<  ['name' => k, 'type' => 'checkbox', 'ui_label' => k ]
							  when "enum"
									@info['Data'] << [ 'name' => k, 'type' => 'combobox', 'ui_label' => k, 'store_type' => 'arraystore', 'store_fields' => ['enum'], 'store_data' => msfoptions[k]['enums'], 'valueField' => 'enum', 'displayField' => 'enum' , 'autoWidth' => true, 'mode' => 'local', 'value' => msfoptions[k]['default']]
								else
									print "K => #{k}\n"
									print "Status => #{msfoptions[k]['advanced']}\n"
								end
				}

				msfpayloads = msf.get_payloads(modname)
				payloads = msfpayloads['payloads']
				pl = []
				payloads.each { |p|
						pl << [p]
			  }	
				
				@info['Data'] << [ 'name' => 'Payload', 
				  'type' => 'combobox', 
					'ui_label' => 'Payload',
					'store_type' => 'arraystore', 
					'store_fields' => ['payload'], 
					'store_data' => pl, 
					'valueField' => 'payload', 
					'displayField' => 'payload' , 
					'autoWidth' => true,
					'mode' => 'local',
					'emptyText' => "select a payload..."]

				
	end

end


end
end
end

#@info = info
#@datastore = @info['Data'] || nil
#@friendlyname = @info['Name'] || nil
#@target = @info['Target'] || nil
#@output = ''
#@path = @info['File'].sub(BeEF::HttpHookServer.instance.root_dir, '')
#@default_command_url = '/command/'+(File.basename @path, '.rb')+'.js'
#@id = BeEF::Models::CommandModule.first(:path => @info['File']).object_id
#@use_template = false
#@auto_update_zombie = false
#@results = {}
#@beefjs_components = {}

