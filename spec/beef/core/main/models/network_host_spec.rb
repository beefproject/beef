#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'extensions/network/models/network_host'

RSpec.describe BeEF::Core::Models::NetworkHost do
  describe 'associations' do
    it 'belongs_to hooked_browser' do
      expect(described_class.reflect_on_association(:hooked_browser)).not_to be_nil
      expect(described_class.reflect_on_association(:hooked_browser).macro).to eq(:belongs_to)
    end
  end

  describe '.create' do
    let(:hooked_browser) { BeEF::Core::Models::HookedBrowser.create!(session: 'test_session', ip: '127.0.0.1') }

    it 'accepts ntype as the host type attribute' do
      host = described_class.create!(
        hooked_browser_id: hooked_browser.id,
        ip: '192.168.1.1',
        ntype: 'Host'
      )

      expect(host).to be_persisted
      expect(host.ntype).to eq('Host')
    end

    it 'rejects type as an unknown attribute (regression guard for #3493 and #3498)' do
      expect {
        described_class.create!(
          hooked_browser_id: hooked_browser.id,
          ip: '192.168.1.1',
          type: 'Host'
        )
      }.to raise_error(ActiveModel::UnknownAttributeError, /unknown attribute 'type'/)
    end
  end
end
