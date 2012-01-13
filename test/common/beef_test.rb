require 'test/unit'

require 'capybara'
Capybara.run_server = false # we need to run our own BeEF server

require 'selenium/webdriver'
require "selenium"

class BeefTest

  def self.save_screenshot(session)
    Dir.mkdir(BEEF_TEST_DIR) if not File.directory?(BEEF_TEST_DIR)
    session.driver.browser.save_screenshot(BEEF_TEST_DIR + Time.now.strftime("%Y-%m-%d--%H-%M-%S-%N") + ".png")
  end

  def self.login(session = nil)
    session = Capybara::Session.new(:selenium) if session.nil?
    session.visit('http://localhost:3000/ui/panel')
    session.has_content?('BeEF Authentication')
    session.fill_in 'user', :with => 'beef'
    session.fill_in 'pass', :with => 'beef'
    session.click_button('Login')

    session
  end

  def self.logout(session)
    session.click_link('Logout')

    session
  end

end