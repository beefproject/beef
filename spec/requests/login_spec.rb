#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'rspec'
require 'spec/support/constants.rb'

RSpec.describe 'Beef Login', run_on_long_tests: true  do
  let(:session) { Capybara::Session.new(:selenium_headless) }

  before(:each) do
    @pid = start_beef_server
  end

  after(:each) do
    stop_beef_server(@pid)
    # BeefTest.save_screenshot(session)
    session.driver.browser.close
  end

  it 'logs in successfully' do
    session.visit(ATTACK_URL)

    expect(session.has_content?('Authentication', wait: 10))
    expect(session.has_no_content?('Hooked Browsers', wait: 10))

    if session.has_field?('user', visible: true)
      session.fill_in 'user', with: BEEF_USER
    end

    if session.has_field?('pass', visible: true)
      session.fill_in 'pass', with: BEEF_PASSWD
    end

    if session.has_button?('Login', visible: true)
      session.click_button('Login')
    end

    expect(session.has_no_content?('Authentication', wait: 10))
    expect(session.has_content?('Hooked Browsers', wait: 10))
  end

  it 'logs out successfully' do
    session = BeefTest.login()

    expect(session).not_to be_nil
    expect(session.has_content?('Hooked Browsers', wait: 10))
    expect(session.has_content?('Logout', wait: 10))

    session.click_link('Logout')

    expect(session.has_no_content?('Hooked Browsers', wait: 10))
    expect(session.has_content?('Logout', wait: 10))
    expect(session.has_content?('BeEF Authentication', wait: 10))
  end

  it 'displays logs tab' do
    session = BeefTest.login()

    expect(session.has_content?('Hooked Browsers', wait: 10))
    expect(session.has_content?('Logout', wait: 10))
    expect(session.has_content?('Logs', wait: 10))

    session.click_on('Logs')

    expect(session).to have_content('Logout', wait: 10)
    expect(session).to have_content('Hooked Browsers', wait: 10)
    expect(session).to have_content('Type', wait: 10)
    expect(session).to have_content('Event', wait: 10)
    expect(session).to have_content('Date', wait: 10)
    expect(session).to have_content('Page', wait: 10)
    expect(session).to have_content('User with ip 127.0.0.1 has successfully authenticated in the application', wait: 10)
  end

  it 'hooks a browser successfully' do
    attacker = BeefTest.new_attacker
    victim = BeefTest.new_victim

    expect(attacker).to have_content('Logout', wait: 10)
    expect(attacker).to have_content(VICTIM_DOMAIN, wait: 10)

    attacker.click_on("127.0.0.1", match: :first)

    expect(attacker).to have_content('Details')
    expect(attacker).to have_content('Commands')

    BeefTest.logout(attacker)
    attacker.driver.browser.close
    victim.driver.browser.close
  end
end