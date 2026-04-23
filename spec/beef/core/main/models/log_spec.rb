#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Models::Log do
  describe 'associations' do
    it 'has_one hooked_browser' do
      expect(described_class.reflect_on_association(:hooked_browser)).not_to be_nil
      expect(described_class.reflect_on_association(:hooked_browser).macro).to eq(:has_one)
    end
  end

  describe '.create' do
    it 'creates a log with logtype, event, and date' do
      log = described_class.create!(
        logtype: 'TestSource',
        event: 'Test event message',
        date: Time.now
      )

      expect(log).to be_persisted
      expect(log.logtype).to eq('TestSource')
      expect(log.event).to eq('Test event message')
    end

    it 'can store hooked_browser_id' do
      hb = BeEF::Core::Models::HookedBrowser.create!(session: 'log_hb', ip: '127.0.0.1')
      log = described_class.create!(
        logtype: 'Hook',
        event: 'Browser hooked',
        date: Time.now,
        hooked_browser_id: hb.id
      )

      expect(log.hooked_browser_id).to eq(hb.id)
    end
  end
end
