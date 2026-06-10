#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'BeEF::Core::Migration' do
  let(:migration) { BeEF::Core::Migration.instance }
  let(:config) { BeEF::Core::Configuration.instance }
  let(:api_registrar) { BeEF::API::Registrar.instance }

  describe '.instance' do
    it 'returns a singleton instance' do
      instance1 = BeEF::Core::Migration.instance
      instance2 = BeEF::Core::Migration.instance
      expect(instance1).to be(instance2)
    end
  end

  describe '#update_db!' do
    it 'calls update_commands!' do
      expect(migration).to receive(:update_commands!)
      expect(migration.update_db!).to be_nil
    end
  end

  describe '#update_commands!' do
    before do
      # Clear existing modules from database
      BeEF::Core::Models::CommandModule.destroy_all

      # Mock API registrar to verify it's called
      allow(api_registrar).to receive(:fire)
    end

    it 'creates new modules from config that are not in database' do
      # Setup config with a new module
      module_config = {
        'test_module' => { 'path' => 'modules/test/' }
      }
      allow(config).to receive(:get).with('beef.module').and_return(module_config)
      allow(config).to receive(:get).with('beef.module.test_module').and_return({ 'path' => 'modules/test/' })

      initial_count = BeEF::Core::Models::CommandModule.count
      migration.update_commands!

      expect(BeEF::Core::Models::CommandModule.count).to eq(initial_count + 1)
      created_module = BeEF::Core::Models::CommandModule.find_by(name: 'test_module')
      expect(created_module).not_to be_nil
      expect(created_module.path).to eq('modules/test/module.rb')
    end

    it 'updates config with database IDs and paths for existing modules' do
      # Create a module in the database first
      existing_module = BeEF::Core::Models::CommandModule.create!(
        name: 'existing_module',
        path: 'modules/existing/module.rb'
      )

      # Setup config to include this existing module
      module_config = {
        'existing_module' => { 'path' => 'modules/existing/' }
      }
      allow(config).to receive(:get).with('beef.module').and_return(module_config)
      allow(config).to receive(:get).with('beef.module.existing_module').and_return({ 'path' => 'modules/existing/' })
      allow(config).to receive(:set)

      migration.update_commands!

      expect(config).to have_received(:set).with('beef.module.existing_module.db.id', existing_module.id)
      expect(config).to have_received(:set).with('beef.module.existing_module.db.path', 'modules/existing/module.rb')
    end

    it 'fires the migrate_commands API event' do
      allow(config).to receive(:get).with('beef.module').and_return({})
      migration.update_commands!
      expect(api_registrar).to have_received(:fire).with(BeEF::API::Migration, 'migrate_commands')
    end

    it 'does not create modules that already exist in database' do
      # Create a module in the database
      BeEF::Core::Models::CommandModule.create!(
        name: 'existing_module',
        path: 'modules/existing/module.rb'
      )

      # Setup config with the same module
      module_config = {
        'existing_module' => { 'path' => 'modules/existing/' }
      }
      allow(config).to receive(:get).with('beef.module').and_return(module_config)
      allow(config).to receive(:get).with('beef.module.existing_module').and_return({ 'path' => 'modules/existing/' })

      initial_count = BeEF::Core::Models::CommandModule.count
      migration.update_commands!

      # Should not create a duplicate
      expect(BeEF::Core::Models::CommandModule.count).to eq(initial_count)
    end
  end
end
