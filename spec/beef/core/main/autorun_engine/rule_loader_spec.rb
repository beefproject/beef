#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::AutorunEngine::RuleLoader do
  let(:loader) { described_class.instance }

  def valid_rule_data
    {
      'name' => 'Test Rule',
      'author' => 'Test Author',
      'browser' => 'ALL',
      'browser_version' => 'ALL',
      'os' => 'Windows',
      'os_version' => 'ALL',
      'modules' => [],
      'execution_order' => [],
      'execution_delay' => [],
      'chain_mode' => 'sequential'
    }
  end

  before do
    allow(loader).to receive(:print_error)
    allow(loader).to receive(:print_info)
    allow(loader).to receive(:print_more)
  end

  describe '#load_rule_json' do
    it 'returns success and rule_id when parse succeeds and rule is new' do
      # Parser will succeed with valid minimal data; no existing rule
      result = loader.load_rule_json(valid_rule_data)

      expect(result['success']).to be true
      expect(result).to have_key('rule_id')
      expect(result['rule_id']).to be_a(Integer)
    end

    it 'returns success false and error when parse raises' do
      allow(BeEF::Core::AutorunEngine::Parser.instance).to receive(:parse).and_raise(ArgumentError.new('Invalid rule name'))

      result = loader.load_rule_json(valid_rule_data.merge('name' => 'x'))

      expect(result['success']).to be false
      expect(result['error']).to include('Invalid rule name')
    end

    it 'returns success false and error when rule already exists' do
      # Create the rule first so it already exists
      BeEF::Core::Models::Rule.create!(
        name: 'Duplicate Rule',
        author: 'Test Author',
        browser: 'ALL',
        browser_version: 'ALL',
        os: 'Windows',
        os_version: 'ALL',
        modules: [].to_json,
        execution_order: [].to_s,
        execution_delay: [].to_s,
        chain_mode: 'sequential'
      )

      result = loader.load_rule_json(
        valid_rule_data.merge('name' => 'Duplicate Rule')
      )

      expect(result['success']).to be false
      expect(result['error']).to include('Duplicate rule already exists')
    end

    it 'uses default chain_mode sequential when missing' do
      data = valid_rule_data.except('chain_mode')
      result = loader.load_rule_json(data)

      expect(result['success']).to be true
      expect(result).to have_key('rule_id')
    end
  end
end
