#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require '../common/test_constants'
require '../common/beef_test'

class TC_login < Test::Unit::TestCase

  def test_log_in
    session = Capybara::Session.new(:selenium)
    session.visit(ATTACK_URL)
    sleep 2.0
    BeefTest.save_screenshot(session)
    session.has_content?('BeEF Authentication')
    session.fill_in 'user', :with => 'beef'
    session.fill_in 'pass', :with => 'beef'
    BeefTest.save_screenshot(session)
    session.click_button('Login')
    sleep 20.0
    session.has_content?('logout')
    BeefTest.save_screenshot(session)
  end

  def test_beef_test_login_function
    session = BeefTest.login
    session.has_content?('logout')
    BeefTest.save_screenshot(session)
  end

  def test_log_out
    session = BeefTest.login
    session.click_link('Logout')
    session.has_content?('BeEF Authentication')
    BeefTest.save_screenshot(session)
  end

  def test_beef_test_logout_function
    session = BeefTest.login
    session = BeefTest.logout(session)
    session.has_content?('BeEF Authentication')
    BeefTest.save_screenshot(session)
  end

  def test_logs_tab
    session = BeefTest.login
    session.click_on('Logs')
    session.has_content?('logout')
    session.has_content?('Hooked Browsers')
    session.has_content?('Type')
    session.has_content?('Event')
    session.has_content?('Date')
    session.has_content?('No logs to display')
    session.has_content?('Page')

    BeefTest.save_screenshot(session)
    BeefTest.logout(session)
  end

  def test_hooking_browser
    attacker = BeefTest.new_attacker
    victim = BeefTest.new_victim

    sleep 5.0

    attacker.has_content?(VICTIM_DOMAIN)
    attacker.has_content?('127.0.0.1')
    attacker.click_on('127.0.0.1')

    sleep 1.0

    attacker.has_content?('Details')
    attacker.has_content?('Commands')
    attacker.has_content?('Rider')

    BeefTest.save_screenshot(attacker)
    BeefTest.save_screenshot(victim)

    BeefTest.logout(attacker)
  end

end