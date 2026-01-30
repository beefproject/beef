#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Models::Result do
  describe 'associations' do
    it 'has_one command' do
      expect(described_class.reflect_on_association(:command)).not_to be_nil
      expect(described_class.reflect_on_association(:command).macro).to eq(:has_one)
    end

    it 'has_one hooked_browser' do
      expect(described_class.reflect_on_association(:hooked_browser)).not_to be_nil
      expect(described_class.reflect_on_association(:hooked_browser).macro).to eq(:has_one)
    end
  end

  describe '.create' do
    let(:hooked_browser) { BeEF::Core::Models::HookedBrowser.create!(session: 'test_session', ip: '127.0.0.1') }
    let(:command_module) { BeEF::Core::Models::CommandModule.create!(name: 'test_module', path: 'modules/test/') }
    let(:command) { BeEF::Core::Models::Command.create!(hooked_browser_id: hooked_browser.id, command_module_id: command_module.id) }

    it 'creates a result with required attributes' do
      result = described_class.create!(
        hooked_browser_id: hooked_browser.id,
        command_id: command.id,
        data: { 'test' => 'data' }.to_json,
        status: 0,
        date: Time.now.to_i
      )

      expect(result).to be_persisted
      expect(result.hooked_browser_id).to eq(hooked_browser.id)
      expect(result.command_id).to eq(command.id)
      expect(result.status).to eq(0)
    end

    it 'can access command_id' do
      result = described_class.create!(
        hooked_browser_id: hooked_browser.id,
        command_id: command.id,
        data: {}.to_json,
        status: 0,
        date: Time.now.to_i
      )

      expect(result.command_id).to eq(command.id)
    end
  end
end
