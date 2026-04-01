#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::AutorunEngine::Parser do
  let(:parser) { described_class.instance }

  def valid_minimal_args
    {
      name: 'Test Rule',
      author: 'Test Author',
      browser: 'ALL',
      browser_version: 'ALL',
      os: 'Windows',
      os_version: 'ALL',
      modules: [],
      execution_order: [],
      execution_delay: [],
      chain_mode: 'sequential'
    }
  end

  describe '#parse' do
    it 'returns true for valid minimal args (empty modules)' do
      result = parser.parse(
        valid_minimal_args[:name],
        valid_minimal_args[:author],
        valid_minimal_args[:browser],
        valid_minimal_args[:browser_version],
        valid_minimal_args[:os],
        valid_minimal_args[:os_version],
        valid_minimal_args[:modules],
        valid_minimal_args[:execution_order],
        valid_minimal_args[:execution_delay],
        valid_minimal_args[:chain_mode]
      )

      expect(result).to be true
    end

    it 'raises ArgumentError for empty name' do
      expect do
        parser.parse('', 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [], [], [], 'sequential')
      end.to raise_error(ArgumentError, /Invalid rule name/)
    end

    it 'raises ArgumentError for nil name' do
      expect do
        parser.parse(nil, 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [], [], [], 'sequential')
      end.to raise_error(ArgumentError, /Invalid rule name/)
    end

    it 'raises ArgumentError for empty author' do
      expect do
        parser.parse('Name', '', 'ALL', 'ALL', 'Windows', 'ALL', [], [], [], 'sequential')
      end.to raise_error(ArgumentError, /Invalid author name/)
    end

    it 'raises ArgumentError for invalid chain_mode' do
      expect do
        parser.parse('Name', 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [], [], [], 'invalid')
      end.to raise_error(ArgumentError, /Invalid chain_mode definition/)
    end

    it 'raises ArgumentError for invalid os' do
      expect do
        parser.parse('Name', 'Author', 'ALL', 'ALL', 'InvalidOS', 'ALL', [], [], [], 'sequential')
      end.to raise_error(ArgumentError, /Invalid os definition/)
    end

    it 'raises ArgumentError when execution_delay size does not match modules size' do
      expect do
        parser.parse('Name', 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [{ 'name' => 'a' }], [1], [], 'sequential')
      end.to raise_error(ArgumentError, /execution_delay.*consistent with number of modules/)
    end

    it 'raises ArgumentError when execution_order size does not match modules size' do
      expect do
        parser.parse('Name', 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [{ 'name' => 'a' }], [], [0], 'sequential')
      end.to raise_error(ArgumentError, /execution_order.*consistent with number of modules/)
    end

    it 'raises TypeError when execution_delay contains non-Integer' do
      # Use one module so sizes match; then type check runs on execution_delay
      expect do
        parser.parse('Name', 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [{}], [1], ['not_an_int'], 'sequential')
      end.to raise_error(TypeError, /execution_delay.*Integers/)
    end

    it 'raises TypeError when execution_order contains non-Integer' do
      # Use one module so sizes match; then type check runs on execution_order
      expect do
        parser.parse('Name', 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [{}], ['x'], [0], 'sequential')
      end.to raise_error(TypeError, /execution_order.*Integers/)
    end

    it 'raises ArgumentError for invalid browser' do
      expect do
        parser.parse('Name', 'Author', 'XX', 'ALL', 'Windows', 'ALL', [], [], [], 'sequential')
      end.to raise_error(ArgumentError, /Invalid browser definition/)
    end

    it 'accepts nested-forward as chain_mode' do
      result = parser.parse('Name', 'Author', 'ALL', 'ALL', 'Windows', 'ALL', [], [], [], 'nested-forward')
      expect(result).to be true
    end

    it 'accepts valid os values' do
      %w[Linux Windows OSX Android iOS BlackBerry ALL].each do |os|
        result = parser.parse('Name', 'Author', 'ALL', 'ALL', os, 'ALL', [], [], [], 'sequential')
        expect(result).to be true
      end
    end
  end
end
