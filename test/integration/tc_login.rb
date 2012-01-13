require 'test/unit'

BEEF_TEST_DIR = "/tmp/beef-test/"

class TC_login < Test::Unit::TestCase

  def save_screenshot(session)
    Dir.mkdir(BEEF_TEST_DIR) if not File.directory?(BEEF_TEST_DIR)
    session.driver.browser.save_screenshot(BEEF_TEST_DIR + Time.now.strftime("%Y-%m-%d--%H-%M-%S-%N") + ".png")
  end

  def test_log_in
    session = Capybara::Session.new(:selenium)
    session.visit('http://localhost:3000/ui/panel')
    save_screenshot(session)
    session.has_content?('BeEF Authentication')
    session.fill_in 'user', :with => 'beef'
    session.fill_in 'pass', :with => 'beef'
    save_screenshot(session)
    session.click_button('Login')
    session.has_content?('logout')
    save_screenshot(session)

    session
  end

  def test_log_out
    session = test_log_in
    session.has_content?('logout')
    session.click_link('Logout')
    save_screenshot(session)
    session.has_content?('BeEF Authentication')
    save_screenshot(session)

    session
  end

end