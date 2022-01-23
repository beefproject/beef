require 'rest-client'

RSpec.describe 'BeEF Extension WebRTC' do
  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config

    # json = {:username => BEEF_USER, :password => BEEF_PASSWD}.to_json
    # @headers = {:content_type => :json, :accept => :json}
    # response = RestClient.post("#{RESTAPI_ADMIN}/login", json, @headers)
    # result = JSON.parse(response.body)
    # @token = result['token']
    # @activated = @config.get('beef.extension.webrtc.enable') || false

    # @victim1 = BeefTest.new_victim
    # @victim2 = BeefTest.new_victim

    # sleep 8

    # # Fetch last online browsers' ids
    # rest_response = RestClient.get "#{RESTAPI_HOOKS}", {:params => { :token => @token}}
    # result = JSON.parse(rest_response.body)
    # browsers = result["hooked-browsers"]["online"]
    # browsers.each_with_index do |elem, index|
    #   if index == browsers.length - 1
    #       @victim2id = browsers["#{index}"]["id"].to_s
    #   end
    #   if index == browsers.length - 2
    #       @victim1id = browsers["#{index}"]["id"].to_s
    #   end
    # end
  end

  after(:all) do
    # @victim1.driver.browser.close unless @victim1.nil?
    # @victim2.driver.browser.close unless @victim2.nil?
  end

  it 'loads configuration' do
    config = @config.get('beef.extension.webrtc')
    expect(config).to have_key('enable')
    expect(config).to have_key('stunservers')
    expect(config).to have_key('turnservers')
  end

  # it 'check two hooked browsers' do
  #   expect(@activated).to be(true)

  #   response = nil
  #   expect {
  #     response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {:token => @token}}
  #   }.to_not raise_error
  #   expect(response).to_not be_nil
  #   expect(response.body).to_not be_nil
  #   expect(response.code).to eql(200)

  #   result = JSON.parse(rest_response.body)
  #   browsers = result["hooked-browsers"]["online"]
  #   expect(browsers).to_not be_nil
  #   expect(browsers.length).to be >= 2
  # end
end
