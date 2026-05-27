#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Constants::Os do
  describe 'constants' do
    it 'defines OS UA strings and image paths' do
      expect(described_class::OS_WINDOWS_UA_STR).to eq('Windows')
      expect(described_class::OS_LINUX_UA_STR).to eq('Linux')
      expect(described_class::OS_MAC_UA_STR).to eq('Mac')
      expect(described_class::OS_ANDROID_UA_STR).to eq('Android')
      expect(described_class::OS_ALL_UA_STR).to eq('All')
      expect(described_class::OS_UNKNOWN_IMG).to eq('unknown.png')
    end
  end

  describe '.match_os' do
    it 'returns Windows for win-like strings' do
      expect(described_class.match_os('Windows')).to eq('Windows')
      expect(described_class.match_os('Windows NT')).to eq('Windows')
      expect(described_class.match_os('Win32')).to eq('Windows')
    end

    it 'returns Linux for lin-like strings' do
      expect(described_class.match_os('Linux')).to eq('Linux')
      expect(described_class.match_os('Lin')).to eq('Linux')
    end

    it 'returns Mac for os x, osx, mac-like strings' do
      expect(described_class.match_os('Mac OS X')).to eq('Mac')
      expect(described_class.match_os('OSX')).to eq('Mac')
      expect(described_class.match_os('Macintosh')).to eq('Mac')
    end

    it 'returns iOS for iphone, ipad, ipod' do
      expect(described_class.match_os('iPhone')).to eq('iOS')
      expect(described_class.match_os('iPad')).to eq('iOS')
      expect(described_class.match_os('iPod')).to eq('iOS')
      expect(described_class.match_os('iOS')).to eq('iOS')
    end

    it 'returns Android for android-like strings' do
      expect(described_class.match_os('Android')).to eq('Android')
    end

    it 'returns BlackBerry for blackberry-like strings' do
      expect(described_class.match_os('BlackBerry')).to eq('BlackBerry')
    end

    it 'returns QNX for qnx-like strings' do
      expect(described_class.match_os('QNX')).to eq('QNX')
    end

    it 'returns SunOS for sun-like strings' do
      expect(described_class.match_os('SunOS')).to eq('SunOS')
    end

    it 'is case insensitive' do
      expect(described_class.match_os('WINDOWS')).to eq('Windows')
      expect(described_class.match_os('linux')).to eq('Linux')
      expect(described_class.match_os('ANDROID')).to eq('Android')
    end

    it 'returns ALL for unknown OS strings' do
      expect(described_class.match_os('UnknownOS')).to eq('ALL')
      expect(described_class.match_os('')).to eq('ALL')
    end
  end
end
