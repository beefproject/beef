#
# Copyright (c) 2006-2024 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'rspec'
require 'spec/support/constants.rb'
# require '../common/beef_test'

RSpec.describe 'Beef Login' do
  let(:session) { Capybara::Session.new(:selenium_headless) }

  before(:each) do
    session.visit(ATTACK_URL)
    sleep 2.0
  end

  after(:each) do
    BeefTest.save_screenshot(session)
    session.driver.browser.close
  end

  it 'logs in successfully' do
    session.fill_in 'user', with: BEEF_USER
    session.fill_in 'pass', with: BEEF_PASSWD
    session.click_button('Login')
    sleep 10.0
    expect(session).to have_content('Logout')
  end

  # it 'logs out successfully' do
  #   session.fill_in 'user', with: BEEF_USER
  #   session.fill_in 'pass', with: BEEF_PASSWD
  #   session.click_button('Login')
  #   sleep 2.0
  #   session.click_link('Logout')
  #   sleep 2.0
  #   expect(session).to have_title('BeEF Authentication')
  # end

  # it 'displays logs tab' do
  #   session.fill_in 'user', with: BEEF_USER
  #   session.fill_in 'pass', with: BEEF_PASSWD
  #   session.click_button('Login')
  #   sleep 2.0
  #   session.click_on('Logs')
  #   expect(session).to have_content('Logout')
  #   expect(session).to have_content('Hooked Browsers')
  #   expect(session).to have_content('Type')
  #   expect(session).to have_content('Event')
  #   expect(session).to have_content('Date')
  #   expect(session).to have_content('Page')
  #   expect(session).to have_content('User with ip 127.0.0.1 has successfully authenticated in the application')
  # end

  # it 'hooks a browser successfully' do
  #   attacker = BeefTest.new_attacker
  #   victim = BeefTest.new_victim

  #   sleep 5.0

  #   expect(attacker).to have_content(VICTIM_DOMAIN)
  #   expect(attacker).to have_content('127.0.0.1')
  #   attacker.click_on("127.0.0.1", match: :first)

  #   sleep 1.0

  #   expect(attacker).to have_content('Details')
  #   expect(attacker).to have_content('Commands')

  #   BeefTest.save_screenshot(attacker)
  #   BeefTest.save_screenshot(victim)

  #   BeefTest.logout(attacker)
  #   attacker.driver.browser.close
  #   victim.driver.browser.close
  # end
end