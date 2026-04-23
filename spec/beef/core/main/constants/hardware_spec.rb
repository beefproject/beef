#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Constants::Hardware do
  describe 'constants' do
    it 'defines hardware UA strings and image paths' do
      expect(described_class::HW_IPHONE_UA_STR).to eq('iPhone')
      expect(described_class::HW_IPAD_UA_STR).to eq('iPad')
      expect(described_class::HW_BLACKBERRY_UA_STR).to eq('BlackBerry')
      expect(described_class::HW_ALL_UA_STR).to eq('All')
      expect(described_class::HW_UNKNOWN_IMG).to eq('pc.png')
    end
  end

  describe '.match_hardware' do
    it 'returns iPhone for iphone-like strings' do
      expect(described_class.match_hardware('iPhone')).to eq('iPhone')
      expect(described_class.match_hardware('iPhone OS')).to eq('iPhone')
    end

    it 'returns iPad for ipad-like strings' do
      expect(described_class.match_hardware('iPad')).to eq('iPad')
    end

    it 'returns iPod for ipod-like strings' do
      expect(described_class.match_hardware('iPod')).to eq('iPod')
    end

    it 'returns BlackBerry for blackberry-like strings' do
      expect(described_class.match_hardware('BlackBerry')).to eq('BlackBerry')
    end

    it 'returns Windows Phone for windows phone-like strings' do
      expect(described_class.match_hardware('Windows Phone')).to eq('Windows Phone')
    end

    it 'returns Kindle for kindle-like strings' do
      expect(described_class.match_hardware('Kindle')).to eq('Kindle')
    end

    it 'returns Nokia for nokia-like strings' do
      expect(described_class.match_hardware('Nokia')).to eq('Nokia')
    end

    it 'returns HTC for htc-like strings' do
      expect(described_class.match_hardware('HTC')).to eq('HTC')
    end

    it 'returns Nexus for google-like strings' do
      expect(described_class.match_hardware('Google Nexus')).to eq('Nexus')
    end

    it 'is case insensitive' do
      expect(described_class.match_hardware('IPHONE')).to eq('iPhone')
      expect(described_class.match_hardware('ipad')).to eq('iPad')
      expect(described_class.match_hardware('BLACKBERRY')).to eq('BlackBerry')
    end

    it 'returns ALL for unknown hardware strings' do
      expect(described_class.match_hardware('UnknownDevice')).to eq('ALL')
      expect(described_class.match_hardware('')).to eq('ALL')
    end
  end
end
