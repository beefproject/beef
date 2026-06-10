#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Filters do
  describe '.is_valid_browsername?' do
    it 'validates browser names' do
      expect(BeEF::Filters.is_valid_browsername?('FF')).to be(true)
      expect(BeEF::Filters.is_valid_browsername?('IE')).to be(true)
      expect(BeEF::Filters.is_valid_browsername?('CH')).to be(true)
      expect(BeEF::Filters.is_valid_browsername?('TOOLONG')).to be(false)
      expect(BeEF::Filters.is_valid_browsername?('')).to be(false)
    end
  end

  describe '.is_valid_osname?' do
    it 'validates OS names' do
      expect(BeEF::Filters.is_valid_osname?('Windows XP')).to be(true)
      expect(BeEF::Filters.is_valid_osname?('A')).to be(false) # too short
      expect(BeEF::Filters.is_valid_osname?('')).to be(false)
    end
  end

  describe '.is_valid_hwname?' do
    it 'validates hardware names' do
      expect(BeEF::Filters.is_valid_hwname?('iPhone')).to be(true)
      expect(BeEF::Filters.is_valid_hwname?('A')).to be(false) # too short
      expect(BeEF::Filters.is_valid_hwname?('')).to be(false)
    end
  end

  describe '.is_valid_browserversion?' do
    it 'validates browser versions' do
      expect(BeEF::Filters.is_valid_browserversion?('1.0')).to be(true)
      expect(BeEF::Filters.is_valid_browserversion?('1.2.3.4')).to be(true)
      expect(BeEF::Filters.is_valid_browserversion?('UNKNOWN')).to be(true)
      expect(BeEF::Filters.is_valid_browserversion?('ALL')).to be(true)
      expect(BeEF::Filters.is_valid_browserversion?('invalid')).to be(false)
    end
  end

  describe '.is_valid_osversion?' do
    it 'validates OS versions' do
      expect(BeEF::Filters.is_valid_osversion?('10.0')).to be(true)
      expect(BeEF::Filters.is_valid_osversion?('UNKNOWN')).to be(true)
      expect(BeEF::Filters.is_valid_osversion?('ALL')).to be(true)
      expect(BeEF::Filters.is_valid_osversion?('invalid!')).to be(false)
    end
  end

  describe '.is_valid_browserstring?' do
    it 'validates browser/UA strings' do
      expect(BeEF::Filters.is_valid_browserstring?('Mozilla/5.0')).to be(true)
      expect(BeEF::Filters.is_valid_browserstring?('A' * 300)).to be(true)
      expect(BeEF::Filters.is_valid_browserstring?('A' * 301)).to be(false)
    end
  end

  describe '.is_valid_cookies?' do
    it 'validates cookie strings' do
      expect(BeEF::Filters.is_valid_cookies?('session=abc123')).to be(true)
      expect(BeEF::Filters.is_valid_cookies?('A' * 2000)).to be(true)
      expect(BeEF::Filters.is_valid_cookies?('A' * 2001)).to be(false)
    end
  end

  describe '.is_valid_browser_plugins?' do
    it 'validates browser plugin strings' do
      expect(BeEF::Filters.is_valid_browser_plugins?('Flash, Java')).to be(true)
      expect(BeEF::Filters.is_valid_browser_plugins?('A' * 1000)).to be(true)
      expect(BeEF::Filters.is_valid_browser_plugins?('A' * 1001)).to be(false)
    end
  end
end
