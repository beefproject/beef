#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Constants::Browsers do
  describe 'constants' do
    it 'defines short browser codes' do
      expect(described_class::FF).to eq('FF')
      expect(described_class::C).to eq('C')
      expect(described_class::IE).to eq('IE')
      expect(described_class::S).to eq('S')
      expect(described_class::ALL).to eq('ALL')
      expect(described_class::UNKNOWN).to eq('UN')
    end

    it 'defines friendly names' do
      expect(described_class::FRIENDLY_FF_NAME).to eq('Firefox')
      expect(described_class::FRIENDLY_C_NAME).to eq('Chrome')
      expect(described_class::FRIENDLY_UN_NAME).to eq('UNKNOWN')
    end
  end

  describe '.friendly_name' do
    it 'returns Firefox for FF' do
      expect(described_class.friendly_name(described_class::FF)).to eq('Firefox')
    end

    it 'returns Chrome for C' do
      expect(described_class.friendly_name(described_class::C)).to eq('Chrome')
    end

    it 'returns Internet Explorer for IE' do
      expect(described_class.friendly_name(described_class::IE)).to eq('Internet Explorer')
    end

    it 'returns Safari for S' do
      expect(described_class.friendly_name(described_class::S)).to eq('Safari')
    end

    it 'returns MSEdge for E' do
      expect(described_class.friendly_name(described_class::E)).to eq('MSEdge')
    end

    it 'returns UNKNOWN for UN' do
      expect(described_class.friendly_name(described_class::UNKNOWN)).to eq('UNKNOWN')
    end

    it 'returns nil for unknown browser code' do
      expect(described_class.friendly_name('XX')).to be_nil
    end

    it 'returns nil for nil' do
      expect(described_class.friendly_name(nil)).to be_nil
    end
  end
end
