require 'test/unit'

class BeefTest

  def self.save_screenshot(session)
    Dir.mkdir(BEEF_TEST_DIR) if not File.directory?(BEEF_TEST_DIR)
    session.driver.browser.save_screenshot(BEEF_TEST_DIR + Time.now.strftime("%Y-%m-%d--%H-%M-%S-%N") + ".png")
  end

end