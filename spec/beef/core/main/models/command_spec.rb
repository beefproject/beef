#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Models::Command do
  describe 'associations' do
    it 'has_many results' do
      expect(described_class.reflect_on_association(:results)).not_to be_nil
      expect(described_class.reflect_on_association(:results).macro).to eq(:has_many)
    end

    it 'has_one command_module' do
      expect(described_class.reflect_on_association(:command_module)).not_to be_nil
      expect(described_class.reflect_on_association(:command_module).macro).to eq(:has_one)
    end

    it 'has_one hooked_browser' do
      expect(described_class.reflect_on_association(:hooked_browser)).not_to be_nil
      expect(described_class.reflect_on_association(:hooked_browser).macro).to eq(:has_one)
    end
  end

  describe '.show_status' do
    it 'returns ERROR for status -1' do
      expect(described_class.show_status(-1)).to eq('ERROR')
    end

    it 'returns SUCCESS for status 1' do
      expect(described_class.show_status(1)).to eq('SUCCESS')
    end

    it 'returns UNKNOWN for status 0' do
      expect(described_class.show_status(0)).to eq('UNKNOWN')
    end

    it 'returns UNKNOWN for any other status' do
      expect(described_class.show_status(2)).to eq('UNKNOWN')
      expect(described_class.show_status(99)).to eq('UNKNOWN')
    end
  end

  describe '.save_result' do
    let(:hooked_browser) { BeEF::Core::Models::HookedBrowser.create!(session: 'cmd_save_session', ip: '127.0.0.1') }
    let(:command_module) { BeEF::Core::Models::CommandModule.create!(name: 'cmd_save_mod', path: 'modules/test/') }
    let(:command) do
      described_class.create!(
        hooked_browser_id: hooked_browser.id,
        command_module_id: command_module.id
      )
    end

    before do
      allow(BeEF::Core::Logger.instance).to receive(:register)
      allow(described_class).to receive(:print_info)
    end

    it 'creates a Result and returns true when all args are valid' do
      result = described_class.save_result(
        'cmd_save_session',
        command.id,
        'Friendly Name',
        { 'output' => 'data' },
        1
      )

      expect(result).to be true
      created = BeEF::Core::Models::Result.last
      expect(created).not_to be_nil
      expect(created.command_id).to eq(command.id)
      expect(created.hooked_browser_id).to eq(hooked_browser.id)
      expect(created.status).to eq(1)
      expect(JSON.parse(created.data)).to eq({ 'output' => 'data' })
    end

    it 'raises TypeError when hook_session_id is not a String' do
      expect do
        described_class.save_result(123, command.id, 'Name', {}, 1)
      end.to raise_error(TypeError, '"hook_session_id" needs to be a string')
    end

    it 'raises TypeError when command_id is not an Integer' do
      expect do
        described_class.save_result('cmd_save_session', '1', 'Name', {}, 1)
      end.to raise_error(TypeError, '"command_id" needs to be an integer')
    end

    it 'raises TypeError when command_friendly_name is not a String' do
      expect do
        described_class.save_result('cmd_save_session', command.id, 123, {}, 1)
      end.to raise_error(TypeError, '"command_friendly_name" needs to be a string')
    end

    it 'raises TypeError when result is not a Hash' do
      expect do
        described_class.save_result('cmd_save_session', command.id, 'Name', 'string', 1)
      end.to raise_error(TypeError, '"result" needs to be a hash')
    end

    it 'raises TypeError when status is not an Integer' do
      expect do
        described_class.save_result('cmd_save_session', command.id, 'Name', {}, '1')
      end.to raise_error(TypeError, '"status" needs to be an integer')
    end

    it 'raises TypeError when hooked_browser is not found for session' do
      expect do
        described_class.save_result('nonexistent_session', command.id, 'Name', {}, 1)
      end.to raise_error(TypeError, 'hooked_browser is nil')
    end

    it 'raises TypeError when command is not found for id and hooked_browser' do
      BeEF::Core::Models::HookedBrowser.create!(session: 'other_session', ip: '127.0.0.1')

      expect do
        described_class.save_result('other_session', command.id, 'Name', {}, 1)
      end.to raise_error(TypeError, 'command is nil')
    end
  end
end
