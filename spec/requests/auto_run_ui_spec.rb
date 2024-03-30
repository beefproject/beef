#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'Auto Run UI API', type: :request do

  before(:each) do
    @pid = start_beef_server_and_wait
    @session = BeefTest.login
	end

	after(:each) do
		# Shutting down server
    BeefTest.logout(@session)
    stop_beef_server(@pid)
	end

  def expect_logged_in
    expect(@session).to have_content('Hooked Browsers', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('Auto Run', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('Logout', wait: PAGE_LOAD_TIMEOUT)
  end

  def expect_auto_run_page
    expect_logged_in
    expect(@session).to have_no_content('Welcome to BeEF', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('Auto Run Rules', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('commands run automatically', wait: PAGE_LOAD_TIMEOUT)
  end

  def navigate_to_auto_run
    expect_logged_in
    
    @session.click_on('Auto Run')

    expect_auto_run_page
  end
  
  def add_new_rule_to_auto_run
    expect_auto_run_page

    @session.click_on('Add New Rule')

    expect(@session).to have_content('Browser(s):', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('Module Name:', wait: PAGE_LOAD_TIMEOUT)
  end

  def delete_rule_from_auto_run
    expect_auto_run_page

    expect(@session).to have_content('Browser(s):', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('Module Name:', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_selector('button', text: 'Delete')

    @session.all('button', text: 'Delete')[1].click
  end

  def delete_all_rules_from_auto_run
    expect_auto_run_page

    @session.all('button', text: 'Delete').each do |button|
      button.click
    end

    expect(@session).to have_no_content('Browser(s):', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_no_content('Module Name:', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_no_selector('button', text: 'Delete', wait: PAGE_LOAD_TIMEOUT)
  end


  def edit_rule_from_auto_run
    expect_auto_run_page

    expect(@session).to have_selector('button', text: 'Edit')
  end

  it 'auto run presented' do
    navigate_to_auto_run
    expect_auto_run_page
  end

  it 'auto run add rule' do
    navigate_to_auto_run
    add_new_rule_to_auto_run
    
    expect(@session).to have_content('Browser(s):', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('Module Name:', wait: PAGE_LOAD_TIMEOUT)

    delete_all_rules_from_auto_run
  end

  it 'auto run delete rule' do
    navigate_to_auto_run
    add_new_rule_to_auto_run

    expect(@session).to have_content('Browser(s):', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_content('Module Name:', wait: PAGE_LOAD_TIMEOUT)

    delete_rule_from_auto_run
    
    expect(@session).to have_no_content('Browser(s):', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_no_content('Module Name:', wait: PAGE_LOAD_TIMEOUT)
  end

  it 'auto run add new rule and run it' do
    navigate_to_auto_run
    delete_all_rules_from_auto_run
    add_new_rule_to_auto_run

    # Fill in the details for the new rule
    @session.all('input')[0].set('Test Data for Name')
    @session.fill_in('Alert text:', with: 'Test Data for Alert Text')

    # Save the new rule
    button = @session.all('button', text: 'Save').first
    expect(button).not_to be_nil
    button.click if button

    # Check if the new rule is displayed
    expect(@session.has_content?('Rule ', wait: PAGE_LOAD_TIMEOUT))
    expect(@session.has_content?('Moldule 1', wait: PAGE_LOAD_TIMEOUT))
    expect(@session).to have_content('Browser(s):', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_selector('button', text: 'Delete', wait: PAGE_LOAD_TIMEOUT)
    expect(@session).to have_selector('button', text: 'Save', wait: PAGE_LOAD_TIMEOUT)

    # Now we need to run the rule and check if the alert is displayed
    victim = BeefTest.new_victim

    timeout = PAGE_LOAD_TIMEOUT
    interval = 0.5 # check every half second
    time_elapsed = 0
    
    while time_elapsed < timeout
      begin
        @alert = victim.driver.browser.switch_to.alert
        @alert.accept
        break
      rescue Selenium::WebDriver::Error::NoSuchAlertError
        sleep interval
        time_elapsed += interval
      end
    end
    
    expect(@alert).not_to be_nil # alert should be present
    expect(victim).to have_content('BeEF', wait: PAGE_LOAD_TIMEOUT)

    # BeefTest.save_screenshot(@session, "./")
    # BeefTest.save_screenshot(victim, "./")

    delete_all_rules_from_auto_run
  end
end
  