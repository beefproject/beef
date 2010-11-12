require "xmlrpc/client"

module BeEF

	class MsfClient < ::XMLRPC::Client

		attr_accessor :token

		def login(user,pass)
			res = self.call("auth.login", user, pass)
			if(not (res and res['result'] == "success"))
					raise RuntimeError, "MSF Authentication failed"
			end
			self.token = res['token']
			true
		end

		def call(meth, *args)
			if(meth != "auth.login")
				if(not self.token)
					raise RuntimeError, "client not authenticated"
				end
				args.unshift(self.token)
			end
			super(meth, *args)
		end

	end
end
