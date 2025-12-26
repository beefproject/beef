#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'selenium-webdriver'
require 'spec_helper'
require 'capybara'
require 'capybara/rspec'
Capybara.run_server = false # we need to run our own BeEF server

class BeefTest
  def self.save_screenshot(session, dir = nil)
    outputDir = dir || BEEF_TEST_DIR
    Dir.mkdir(outputDir) unless File.directory?(outputDir)
    filename = outputDir + Time.now.strftime('%Y-%m-%d--%H-%M-%S-%N') + '.png'
    session.driver.browser.save_screenshot(filename)
  end

  def self.login(session = nil)
    session = Capybara::Session.new(:selenium_headless) if session.nil?
    session.visit(ATTACK_URL)
    
    session.has_content?('Authentication', wait: 10)

    # enter the credentials
    session.execute_script("document.getElementById('pass').value = '#{CGI.escapeHTML(BEEF_PASSWD)}'\;")
    session.execute_script("document.getElementById('user').value = '#{CGI.escapeHTML(BEEF_USER)}'\;")

    # due to using JS there seems to be a race condition - this is a workaround
    session.has_content?('beef', wait: PAGE_LOAD_TIMEOUT)

    # click the login button
    login_script = <<-JAVASCRIPT
      var loginButton;
      var buttons = document.getElementsByTagName('button');
      for (var i = 0; i < buttons.length; i++) {
        if (buttons[i].textContent === 'Login') {
          loginButton = buttons[i];
          break;
        }
      }
      if (loginButton) {
        loginButton.click();
      }
    JAVASCRIPT
    session.execute_script(login_script)

    session.has_content?('Hooked Browsers', wait: PAGE_LOAD_TIMEOUT)

    session
  end

  def self.logout(session)
    session.click_on('Logout')
    session.has_content?('Authentication', wait: PAGE_LOAD_TIMEOUT)

    session
  end

  def self.new_attacker(session = nil)
    self.login(session)
  end

  def self.new_victim(victim = nil)
    victim = Capybara::Session.new(:selenium_headless) if victim.nil?
    victim.visit(VICTIM_URL)
    victim.has_content?('You should be hooked into BeEF.', wait: PAGE_LOAD_TIMEOUT)
    # self.save_screenshot(victim, "./")
    victim
  end
end
