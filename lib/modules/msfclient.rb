module BeEF
  
  #
  # XML RPC Client for Metasploit
  #
	class MsfClient < ::XMLRPC::Client

	  def initialize
			@config = BeEF::Configuration.instance
			@enabled = (@config.get('enable_msf').to_i > 0)
		  return if (not @enabled)
			host = @config.get('msf_host')
			path = @config.get('msf_path')
			port = @config.get('msf_port')
			@un = @config.get('msf_user')
			@pw = @config.get('msf_pass')

			if(not host or not path or not port or not @un or not @pw)
				raise RuntimeError, "#{@enabled}:Insufficient information to initliaze Metasploit"
				@enabled = false
			end

			@token = nil
			@lastauth = nil

			super(host,path,port)


	  end	
		
		# is metasploit enabled in the configuration
		def is_enabled
			@enabled	
		end

    # login into metasploit
		def login
			res = self.call("auth.login", @un ,@pw )
		 	raise RuntimeError, "MSF Authentication failed" if(not (res and res['result'] == "success")) 
			@token = res['token']
			@lastauth = Time.now
			
			true

		end
    
    # sends commands to the metasploit xml rpc server
		def call(meth, *args)
			if(meth != "auth.login")
				raise RuntimeError, "client not authenticated" if(not @token)  
				args.unshift(@token)
			end
			
			super(meth, *args)
		end

		def browser_exploits()
				res = self.call('module.exploits')
				raise RuntimeError, "Metasploit exploit retreval failed" if(not res['modules'])  
				mods = res['modules']
				ret = []
				mods.each do |m|
					ret << m if(m.include? '/browser/')
				end
				ret.sort
		end

		def get_exploit_info(name)
			res = self.call('module.info','exploit',name)
			res
		end
		def get_payloads(name)
			res = self.call('module.compatible_payloads',name)
			res
		end
		def get_options(name)
			res = self.call('module.options','exploit',name)
			res
		end
		def payloads()
			res = self.call('module.payloads')
			res['modules']
		end
		def payload_options(name)
			res = self.call('module.options','payload',name)
			res
		end
		
	end
	
end
