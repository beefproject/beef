module BeEF
  
  #
  # XML RPC Client for Metasploit
  #
	class MsfClient < ::XMLRPC::Client
		include Singleton

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
				print "There is not enough information to initalize Metasploit connectivity at this time.  Please check your options in config.ini to verify that all information is present\n"
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
		 	if(not (res and res['result'] == "success")) 
				@enabled = false
				return false
			end
			@token = res['token']
			@lastauth = Time.now
			
			true

		end
    
    # sends commands to the metasploit xml rpc server
		def call(meth, *args)
			return if not @enabled
			if(meth != "auth.login")
				self.login() if not @token
				args.unshift(@token)
			end
			
			begin
				super(meth, *args)
			rescue Errno::ECONNREFUSED
				print "WARNING: Connection to Metasploit backend failed.  This is typically because it is either not running your connection information is incorrect, please verify this information and try again.  Metasploit capabilities have been disabled until this is fixed\n"
				@enabled = false
				return false
			rescue XMLRPC::FaultException => e
				if e.faultCode == 401 and meth == "auth.login"
					print "WARNING: Your username and password combination was rejected by the Metasploit backend server.  Please verify your settings and restart the BeEF server.  Metasploit connectivity has been disabled.\n"
					@enabled = false
				elsif e.faultCode == 401
					res = self.login()
				else
					print "WARNING: An unknown exception has occured while talking to the Metasploit backend.  The Exception text is (#{e.faultCode} : #{e.faultString}. Please check the Metasploit logs for more details.\n"
				end
				return false
			rescue Exception => e
					print "WARNING: An unknown exception (#{e}) has occured while talking to the Metasploit backend.  Please check the Metasploit logs for more details.\n"
					return false
			end

		end

		def browser_exploits()
				return if not @enabled

				res = self.call('module.exploits')
				return [] if not res or not res['modules']

				mods = res['modules']
				ret = []
				mods.each do |m|
					ret << m if(m.include? '/browser/')
				end

				ret.sort
		end

		def get_exploit_info(name)
			return if not @enabled
			res = self.call('module.info','exploit',name)
			res || {}
		end
		def get_payloads(name)
			return if not @enabled
			res = self.call('module.compatible_payloads',name)
			res || {}
		end
		def get_options(name)
			return if not @enabled
			res = self.call('module.options','exploit',name)
			res || {}
		end
		def payloads()
			return if not @enabled
			res = self.call('module.payloads')
			return {} if not res or not res['modules']
			res['modules']
		end
		def payload_options(name)
			return if not @enabled
			res = self.call('module.options','payload',name)
			return {} if not res
			res
		end
		def launch_exploit(exploit,opts)
				return if not @enabled
				begin
					res = self.call('module.execute','exploit',exploit,opts)
				rescue Exception => e
					print "Exploit failed for #{exploit} \n"
					return false
				end

				uri = ""
				if opts['SSL'] 
					uri += "https://"
				else
					uri += "http://"
				end

				uri += @config.get('msf_callback_host') + ":" + opts['SRVPORT'] + "/" + opts['URIPATH']

				res['uri'] = uri
				res
		end

		
	end
	
end
