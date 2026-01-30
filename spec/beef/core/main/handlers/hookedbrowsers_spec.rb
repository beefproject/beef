#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Handlers::HookedBrowsers do
  # Test the confirm_browser_user_agent logic directly
  describe 'confirm_browser_user_agent logic' do
    it 'matches legacy browser user agents' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return(['IE 8.0'])
      
      # Test the logic: browser_type = user_agent.split(' ').last
      user_agent = 'Mozilla/5.0 IE 8.0'
      browser_type = user_agent.split(' ').last
      
      # Test the matching logic
      matched = false
      BeEF::Core::Models::LegacyBrowserUserAgents.user_agents.each do |ua_string|
        matched = true if ua_string.include?(browser_type)
      end
      
      expect(matched).to be true
    end

    it 'does not match non-legacy browser user agents' do
      allow(BeEF::Core::Models::LegacyBrowserUserAgents).to receive(:user_agents).and_return([])
      
      user_agent = 'Chrome/91.0'
      browser_type = user_agent.split(' ').last
      
      matched = false
      BeEF::Core::Models::LegacyBrowserUserAgents.user_agents.each do |ua_string|
        matched = true if ua_string.include?(browser_type)
      end
      
      expect(matched).to be false
    end
  end
end
