require 'test/unit'
require '../common/test_constants'
require '../common/beef_test'

class TC_login < Test::Unit::TestCase

  def test_log_in
    session = Capybara::Session.new(:selenium)
    session.visit('http://localhost:3000/ui/panel')
    BeefTest.save_screenshot(session)
    session.has_content?('BeEF Authentication')
    session.fill_in 'user', :with => 'beef'
    session.fill_in 'pass', :with => 'beef'
    BeefTest.save_screenshot(session)
    session.click_button('Login')
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
    session = BeefTest.logout(session)
  end

end