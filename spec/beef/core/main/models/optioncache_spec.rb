#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Models::OptionCache do
  describe '.first_or_create' do
    it 'creates a new option cache with a name' do
      name = 'test_option'
      option = described_class.first_or_create(name: name)

      expect(option).to be_persisted
      expect(option.name).to eq(name)
      expect(option.value).to be_nil
    end

    it 'returns existing option cache if it already exists' do
      name = 'existing_option'
      existing = described_class.create!(name: name, value: 'existing_value')

      option = described_class.first_or_create(name: name)

      expect(option.id).to eq(existing.id)
      expect(option.name).to eq(name)
      expect(option.value).to eq('existing_value')
    end
  end

  describe '.where' do
    it 'finds option cache by name' do
      name = 'findable_option'
      described_class.create!(name: name, value: 'test_value')

      option = described_class.where(name: name).first

      expect(option).not_to be_nil
      expect(option.name).to eq(name)
      expect(option.value).to eq('test_value')
    end

    it 'returns nil when option cache does not exist' do
      option = described_class.where(name: 'non_existent').first

      expect(option).to be_nil
    end
  end

  describe 'attributes' do
    it 'can set and retrieve name' do
      option = described_class.new(name: 'test_name')
      expect(option.name).to eq('test_name')
    end

    it 'can set and retrieve value' do
      option = described_class.new(value: 'test_value')
      expect(option.value).to eq('test_value')
    end
  end
end
