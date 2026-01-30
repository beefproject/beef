#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Models::LegacyBrowserUserAgents do
  describe '.user_agents' do
    it 'returns an array' do
      expect(described_class.user_agents).to be_a(Array)
    end

    it 'returns an array that can be iterated' do
      result = described_class.user_agents.map { |ua| ua }

      expect(result).to be_a(Array)
    end
  end
end
