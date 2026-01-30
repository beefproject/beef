#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Filters do
  describe '.is_valid_path_info?' do
    it 'validates path info' do
      expect(BeEF::Filters.is_valid_path_info?('/path/to/resource')).to be(true)
      expect(BeEF::Filters.is_valid_path_info?("\x00")).to be(false)
      expect(BeEF::Filters.is_valid_path_info?(nil)).to be(false)
    end
  end

  describe '.is_valid_hook_session_id?' do
    it 'validates hook session IDs' do
      expect(BeEF::Filters.is_valid_hook_session_id?('abc123')).to be(true)
      expect(BeEF::Filters.is_valid_hook_session_id?('')).to be(false)
      expect(BeEF::Filters.is_valid_hook_session_id?(nil)).to be(false)
    end
  end

  describe '.is_valid_command_module_datastore_key?' do
    it 'validates datastore keys' do
      expect(BeEF::Filters.is_valid_command_module_datastore_key?('test_key')).to be(true)
      expect(BeEF::Filters.is_valid_command_module_datastore_key?('')).to be(false)
    end
  end

  describe '.is_valid_command_module_datastore_param?' do
    it 'validates datastore params' do
      expect(BeEF::Filters.is_valid_command_module_datastore_param?('test_value')).to be(true)
      expect(BeEF::Filters.is_valid_command_module_datastore_param?("\x00")).to be(false)
    end
  end

  describe '.has_valid_key_chars?' do
    it 'validates key characters' do
      expect(BeEF::Filters.has_valid_key_chars?('test_key')).to be(true)
      expect(BeEF::Filters.has_valid_key_chars?('')).to be(false)
    end
  end

  describe '.has_valid_param_chars?' do
    it 'false' do
      chars = [nil, '', '+']
      chars.each do |c|
        expect(BeEF::Filters.has_valid_param_chars?(c)).to be(false)
      end
    end

    it 'true' do
      expect(BeEF::Filters.has_valid_param_chars?('A')).to be(true)
    end
  end
end
