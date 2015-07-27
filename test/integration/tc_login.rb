#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require '../common/test_constants'
require '../common/beef_test'
require 'rspec/expectations'

class TC_Login < Test::Unit::TestCase
  include RSpec::Matchers

  def test_log_in
    session = Capybara::Session.new(:selenium)
    session.visit(ATTACK_URL)
    sleep 2.0
    BeefTest.save_screenshot(session)
    session.should have_title('BeEF Authentication')
    session.fill_in 'user', :with => 'beef'
    session.fill_in 'pass', :with => 'beef'
    BeefTest.save_screenshot(session)
    session.click_button('Login')
    sleep 10.0
    session.should have_content('Logout')
    BeefTest.save_screenshot(session)
    session.driver.browser.close
  end

  def test_beef_test_login_function
    session = BeefTest.login
    session.should have_content('Logout')
    BeefTest.save_screenshot(session)
    session.driver.browser.close
  end

  def test_log_out
    session = BeefTest.login
    session.click_link('Logout')
    sleep 2.0
    session.should have_title('BeEF Authentication')
    BeefTest.save_screenshot(session)
    session.driver.browser.close
  end

  def test_beef_test_logout_function
    session = BeefTest.login
    session = BeefTest.logout(session)
    sleep 2.0
    session.should have_title('BeEF Authentication')
    BeefTest.save_screenshot(session)
    session.driver.browser.close
  end

  def test_logs_tab
    session = BeefTest.login
    session.click_on('Logs')
    session.should have_content('Logout')
    session.should have_content('Hooked Browsers')
    session.should have_content('Type')
    session.should have_content('Event')
    session.should have_content('Date')
    session.should have_content('Page')
    session.should have_content('User with ip 127.0.0.1 has successfuly authenticated in the application')

    BeefTest.save_screenshot(session)
    BeefTest.logout(session)
    session.driver.browser.close
  end

  def test_hooking_browser
    attacker = BeefTest.new_attacker
    victim = BeefTest.new_victim

    sleep 5.0

    attacker.should have_content(VICTIM_DOMAIN)
    attacker.should have_content('127.0.0.1')
    attacker.click_on('127.0.0.1')

    sleep 1.0

    attacker.should have_content('Details')
    attacker.should have_content('Commands')
    attacker.should have_content('Rider')

    BeefTest.save_screenshot(attacker)
    BeefTest.save_screenshot(victim)

    BeefTest.logout(attacker)
    attacker.driver.browser.close
    victim.driver.browser.close
  end

end
