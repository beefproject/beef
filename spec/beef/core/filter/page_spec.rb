#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Filters do
  describe '.is_valid_pagetitle?' do
    it 'validates page titles' do
      expect(BeEF::Filters.is_valid_pagetitle?('Test Page')).to be(true)
      expect(BeEF::Filters.is_valid_pagetitle?('A' * 500)).to be(true)
      expect(BeEF::Filters.is_valid_pagetitle?('A' * 501)).to be(false)
      expect(BeEF::Filters.is_valid_pagetitle?("\x00")).to be(false)
    end
  end

  describe '.is_valid_pagereferrer?' do
    it 'validates page referrers' do
      expect(BeEF::Filters.is_valid_pagereferrer?('http://example.com')).to be(true)
      expect(BeEF::Filters.is_valid_pagereferrer?('A' * 350)).to be(true)
      expect(BeEF::Filters.is_valid_pagereferrer?('A' * 351)).to be(false)
    end
  end
end
