#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Models::CommandModule do
  describe 'associations' do
    it 'has_many commands' do
      expect(described_class.reflect_on_association(:commands)).not_to be_nil
      expect(described_class.reflect_on_association(:commands).macro).to eq(:has_many)
    end
  end

  describe '.create' do
    it 'creates a command module with name and path' do
      mod = described_class.create!(name: 'test_module', path: 'modules/test/')

      expect(mod).to be_persisted
      expect(mod.name).to eq('test_module')
      expect(mod.path).to eq('modules/test/')
    end
  end
end
