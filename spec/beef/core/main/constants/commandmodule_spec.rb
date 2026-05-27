#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Constants::CommandModule do
  describe 'constants' do
    it 'defines verified working status values' do
      expect(described_class::VERIFIED_WORKING).to eq(0)
      expect(described_class::VERIFIED_UNKNOWN).to eq(1)
      expect(described_class::VERIFIED_USER_NOTIFY).to eq(2)
      expect(described_class::VERIFIED_NOT_WORKING).to eq(3)
    end
  end
end
