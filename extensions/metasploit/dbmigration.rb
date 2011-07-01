module BeEF
module Extension
module Metasploit
  
  module DbMigration
    
    extend BeEF::API::Migration
    
    def self.migrate_commands!
      msf = BeEF::Extension::Metasploit::RpcClient.instance
      
      # verify that metasploit is enabled and we are logged in.
      if(msf.is_enabled && msf.login())
        Thread.new() {
          begin
	          sploits = msf.browser_exploits()
  	        sploits.each do |sploit|
  	          if not BeEF::Core::Models::CommandModule.first(:name => sploit)
  			        mod = BeEF::Core::Models::CommandModule.new(:path => "Dynamic/Msf", :name => sploit)
  			        mod.save
  			        if mod.dynamic_command_info == nil
  				        msfi = msf.get_exploit_info(sploit)
  				        st = sploit.split('/').first
  				        targets = []
              
  				        os_name = BeEF::Core::Constants::Os::match_os(st)
                  
  				        browsers =  BeEF::Core::Constants::Browsers::match_browser(msfi['name'] + msfi['targets'].to_json)
                  targets << {'os_name' => os_name, 'browser_name' => 'ALL', 'verified_status' =>
                      BeEF::Core::Constants::CommandModule::VERIFIED_UNKNOWN} if browsers.count == 0

						      browsers.each do |bn|
							        targets << {'os_name' => os_name, 'browser_name' => bn, 'verified_status' =>
                                  BeEF::Core::Constants::CommandModule::VERIFIED_WORKING
                                 }
						      end

                  targets << {'os_name' => "ALL", 'verified_status' => BeEF::Core::Constants::CommandModule::VERIFIED_NOT_WORKING}

  				        msfci = BeEF::Core::Models::DynamicCommandInfo.new(
  							    :name => msfi['name'],
  							    :description => msfi['description'],
  							    :targets => targets.to_json)
                
  				          mod.dynamic_command_info = msfci
  				          mod.save
  			        end
  		        end
  	        end
        
  	        payloads = msf.payloads()
  	        payloads.each do |payload|
  		        if not  BeEF::Core::Models::DynamicPayloads.first( :name => payload)
  			        pl = BeEF::Core::Models::DynamicPayloads.new( :name => payload)
  			        pl.save
  			        opts = msf.payload_options(payload)
  			        opts.keys.each do |opt|
  				        next if opts[opt]['advanced'] or opts[opt]['evasion']
  				        pl.dynamic_payload_info.new(:name => opt, :description => opts[opt]['desc'], :required => opts[opt]['required'], :value => opts[opt]['default'])
  			        end
  			        pl.save
  		        end
    	      end
    	    
    	    # Catching and printing exceptions in regards to migration
    	    # of Metasploit exploits into BeEF
    	    rescue Exception => e
            puts e.message  
            puts e.backtrace
          end
          msf.launch_autopwn()

        }#thread end
      end
    end
    
  end
  
end
end
end
