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
    puts module_name
    expect(@beef_session).to have_content(module_name, wait: PAGE_LOAD_TIMEOUT)
    @beef_session.click_on(module_name)
  end

  it 'Test beef.debug module' do
    click_on_debug_module('Test beef.debug')
    expect(@beef_session).to have_content('Execute', wait: PAGE_LOAD_TIMEOUT)
    BeefTest.save_screenshot(@beef_session, "./")
    #TODO: 'Implement the rest of the test'
  end
end
