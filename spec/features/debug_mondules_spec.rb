#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'rspec'
require 'rest-client'
require 'spec/support/constants.rb'

RSpec.describe 'Debug Modules Integration' do
  before(:each) do
    reset_beef_db
    @pid = start_beef_server_and_wait
    @beef_session = BeefTest.login
    @hooked_browser = BeefTest.new_victim

    expect(@hooked_browser).not_to be_nil
    expect(@hooked_browser).to be_a(Capybara::Session)
    expect(@hooked_browser).to have_content('BeEF', wait: PAGE_LOAD_TIMEOUT)

    expect(@beef_session).not_to be_nil
    expect(@beef_session).to be_a(Capybara::Session)
    expect(@beef_session).to have_content('Hooked Browsers', wait: PAGE_LOAD_TIMEOUT)

    navigate_to_debug_modules
  end

  after(:each) do
    stop_beef_server(@pid)
    @beef_session.driver.browser.close
    @hooked_browser.driver.browser.close
  end

  def navigate_to_hooked_browser(hooked_browser_text = nil)
    expect(@beef_session).to have_content('Hooked Browsers', wait: PAGE_LOAD_TIMEOUT)

    # BeefTest.save_screenshot(@beef_session, "./")
    hooked_browser_text = '127.0.0.1' if hooked_browser_text.nil?
    expect(@beef_session).to have_content(hooked_browser_text, wait: BROWSER_HOOKING_TIMEOUT)

    # click on the hooked browser in the leaf
    @beef_session.all('a', text: hooked_browser_text)[1].click
    expect(@beef_session).to have_content('Commands', wait: PAGE_LOAD_TIMEOUT)
  end

  def navigate_to_debug_modules
    navigate_to_hooked_browser unless @beef_session.has_content?('Current Browser')
    @beef_session.click_on('Commands')
    expect(@beef_session).to have_content('Debug', wait: PAGE_LOAD_TIMEOUT)
    @beef_session.click_on('Debug')
    expect(@beef_session).to have_content('Test beef.debug', wait: PAGE_LOAD_TIMEOUT)
  end

  def click_on_debug_module(module_name)
    navigate_to_debug_modules unless @beef_session.has_content?('Current Browser')
    expect(@beef_session).to have_content(module_name, wait: PAGE_LOAD_TIMEOUT)
    @beef_session.click_on(module_name)
  end

  it 'Test beef.debug module' do
    click_on_debug_module('Test beef.debug')
    expect(@beef_session).to have_content('Execute', wait: PAGE_LOAD_TIMEOUT)
    BeefTest.save_screenshot(@beef_session, "./")
    #TODO: 'Implement the rest of the test'
end

it "Load all debug modules" do
    Dir.glob("modules/debug/**/config.yaml").each do |file|
        module_yaml_data = YAML.load_file(file)
        
        module_yaml_data['beef']['module'].each do |module_key, module_value|
            module_category = module_value['category']
            module_name = module_value['name']
            # some descriptions are too long and include html tags
            module_description_sub = module_value['description'][0, 20]

            expect(@beef_session).to have_content(module_category, wait: PAGE_LOAD_TIMEOUT)
            expect(module_category).not_to be_nil
            expect(module_category).to be_a(String)
            expect(module_name).not_to be_nil
            expect(module_name).to be_a(String)
            expect(module_description_sub).not_to be_nil
            expect(module_description_sub).to be_a(String)
            
            click_on_debug_module(module_name)

            expect(@beef_session).to have_content(module_description_sub, wait: PAGE_LOAD_TIMEOUT)
            expect(@beef_session).to have_content('Execute', wait: PAGE_LOAD_TIMEOUT)

            click_on_debug_module('Execute')
            
            expect(@beef_session).to have_content('command 1', wait: PAGE_LOAD_TIMEOUT)
            
            @beef_session.all('div.x-grid3-cell-inner').each do |div|
                if div.text == 'command 1'
                    div.click
                    break
                end
            end
            
            if module_name == 'Return Image'
                image_selector = "img[src^='data:image/png;base64,iVBORw0KGgo']"
                expect(@beef_session).to have_css(image_selector, wait: PAGE_LOAD_TIMEOUT) 
            else
                expect(@beef_session).to have_content('data: ', wait: PAGE_LOAD_TIMEOUT)
            end
            # BeefTest.save_screenshot(@hooked_browser, "./")
        end
    end
  end
end
