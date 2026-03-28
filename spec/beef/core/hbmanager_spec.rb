#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::HBManager do
  describe '.get_by_session' do
    it 'returns the hooked browser when session exists' do
      hb = BeEF::Core::Models::HookedBrowser.create!(session: 'hb_session_123', ip: '127.0.0.1')

      result = described_class.get_by_session('hb_session_123')

      expect(result).to eq(hb)
      expect(result.session).to eq('hb_session_123')
    end

    it 'returns nil when no hooked browser has the session' do
      result = described_class.get_by_session('nonexistent_session')

      expect(result).to be_nil
    end
  end

  describe '.get_by_id' do
    it 'returns the hooked browser when id exists' do
      hb = BeEF::Core::Models::HookedBrowser.create!(session: 'hb_by_id', ip: '127.0.0.1')

      result = described_class.get_by_id(hb.id)

      expect(result).to eq(hb)
      expect(result.id).to eq(hb.id)
    end

    it 'raises when id does not exist' do
      expect { described_class.get_by_id(999_999) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
