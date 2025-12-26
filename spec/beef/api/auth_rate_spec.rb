#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF API Rate Limit', run_on_long_tests: true  do

	before(:each) do
        @pid = start_beef_server_and_wait
        @username = @config.get('beef.credentials.user')
        @password = @config.get('beef.credentials.passwd')
	end

	after(:each) do
		# Shutting down server
        Process.kill("KILL", @pid) unless @pid.nil?
        Process.wait(@pid) unless @pid.nil? # Ensure the process has exited and the port is released 
        @pid = nil
	end

    it 'confirm correct creds are successful' do
        test_api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', @username, @password) 
        expect(@config.get('beef.credentials.user')).to eq('beef')
        expect(@config.get('beef.credentials.passwd')).to eq('beef')
        expect(test_api.auth()[:payload]).not_to eql("401 Unauthorized") 
        expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed
    end
    
    it 'confirm incorrect creds are unsuccessful' do
        sleep 0.5
        test_api = BeefRestClient.new('http', ATTACK_DOMAIN, '3000', @username, "wrong_passowrd") 
        expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
    end
    
    it 'adheres to 9 bad passwords then 1 correct auth rate limits' do
        # create api structures with bad passwords and one good
		passwds = (1..9).map { |i| "bad_password"} # incorrect password
		passwds.push @password # correct password
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', @username, pswd) }

        (0..apis.length-1).each do |i|
            test_api = apis[i]
            expect(test_api.auth()[:payload]).to eql("401 Unauthorized") # all (unless the valid is first 1 in 10 chance)
        end
    end
    
    it 'adheres to random bad passords and 1 correct auth rate limits' do
        # create api structures with bad passwords and one good
		passwds = (1..9).map { |i| "bad_password"} # incorrect password
		passwds.push @password # correct password
		apis = passwds.map { |pswd| BeefRestClient.new('http', ATTACK_DOMAIN, '3000', @username, pswd) }

        apis.shuffle! # random order for next iteration
        apis = apis.reverse if (apis[0].is_pass?(@password)) # prevent the first from having valid passwd

        (0..apis.length-1).each do |i|
            test_api = apis[i]
            if (test_api.is_pass?(@password))
                sleep 0.5
                expect(@config.get('beef.credentials.user')).to eq('beef')
                expect(@config.get('beef.credentials.passwd')).to eq('beef')
                expect(test_api.auth()[:payload]).not_to eql("401 Unauthorized") 
                expect(test_api.auth()[:payload]["success"]).to be(true) # valid pass should succeed
            else
                expect(test_api.auth()[:payload]).to eql("401 Unauthorized")
            end
        end
    end    
 
end
