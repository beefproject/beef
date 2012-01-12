require 'test/unit'

class TC_login < Test::Unit::TestCase
  include Capybara::DSL

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def test_log_in
    session = Capybara::Session.new(:selenium)
    session.visit('http://localhost:3000/ui/panel')
    session.has_content?('BeEF Authentication')
    session.fill_in 'user', :with => 'beef'
    session.fill_in 'pass', :with => 'beef'
    session.click_button('Login')
    session.has_content?('logout')

    session
  end


  def test_log_out
    session = test_log_in
    session.has_content?('logout')
    session.click_link('Logout')
    session.has_content?('BeEF Authentication')

    session
  end

end