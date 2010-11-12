module BeEF
  
  #
  # XML RPC Client for Metasploit
  #
	class MsfClient < ::XMLRPC::Client

		attr_accessor :token
    
    # login into metasploit
		def login(user,pass)
			res = self.call("auth.login", user, pass)
			if(not (res and res['result'] == "success")) raise RuntimeError, "MSF Authentication failed"
			self.token = res['token']
			
			true
		end
    
    # sends commands to the metasploit xml rpc server
		def call(meth, *args)
			if(meth != "auth.login")
				if(not self.token) raise RuntimeError, "client not authenticated"
				args.unshift(self.token)
			end
			
			super(meth, *args)
		end

	end
	
end
