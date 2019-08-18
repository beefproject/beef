#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF API Rate Limit' do

	before(:all) do
		DataMapper.setup(:default, 'sqlite3::memory:')
		DataMapper.auto_migrate!
		@config = BeEF::Core::Configuration.instance
		http_hook_server = BeEF::Core::Server.instance
		http_hook_server.prepare
		BeEF::API::Registrar.instance.fire(BeEF::API::Server, 'pre_http_start', http_hook_server)
		@pid = fork do
			http_hook_server.start
		end
		# wait for server to start
		sleep 1
	end

	after(:all) do
		Process.kill("INT",@pid)
	end

	it 'adheres to auth rate limits' do
		passwds = (1..9).map { |i| "broken_pass"}
		passwds.push BEEF_PASSWD
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', BEEF_USER, pswd) }
		l = apis.length
		(0..2).each do |again|      # multiple sets of auth attempts
		  # first pass -- apis in order, valid passwd on 9th attempt
		  # subsequent passes apis shuffled
		  puts "speed requesets"    # all should return 401
		  (0..50).each do |i|
			# t = Time.now()
			#puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"
			test_api = apis[i%l]
			expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
			# t0 = t
		  end
		  # again with more time between calls -- there should be success (1st iteration)
		  puts "delayed requests"
		  (0..(l*2)).each do |i|
			# t = Time.now()
			#puts "#{i} : #{t - t0} : #{apis[i%l].auth()[:payload]}"
			test_api = apis[i%l]
			if (test_api.is_pass?(BEEF_PASSWD))
				expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed
			else
				expect(test_api.auth()[:payload]).to eql("401 Unauthorized")
			end
			sleep(0.5)
			# t0 = t
		  end
		  apis.shuffle! # new order for next iteration
		  apis.reverse if (apis[0].is_pass?(BEEF_PASSWD)) # prevent the first from having valid passwd
		end                         # multiple sets of auth attempts
	end
 
end
