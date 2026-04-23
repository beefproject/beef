#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Console::CommandLine do
  DEFAULT_OPTIONS = {
    verbose: false,
    resetdb: false,
    ascii_art: false,
    ext_config: '',
    port: '',
    ws_port: '',
    update_disabled: false,
    update_auto: false
  }.freeze

  def reset_commandline_state
    described_class.instance_variable_set(:@already_parsed, false)
    described_class.instance_variable_set(:@options, DEFAULT_OPTIONS.dup)
  end

  before do
    reset_commandline_state
  end

  describe '.parse' do
    it 'returns default options when ARGV is empty' do
      original_argv = ARGV.dup
      ARGV.replace([])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:verbose]).to be false
      expect(result[:resetdb]).to be false
      expect(result[:ext_config]).to eq('')
      expect(result[:port]).to eq('')
    end

    it 'sets verbose when -v is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-v])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:verbose]).to be true
    end

    it 'sets resetdb when -x is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-x])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:resetdb]).to be true
    end

    it 'sets ascii_art when -a is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-a])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:ascii_art]).to be true
    end

    it 'sets ext_config when -c FILE is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-c custom.yaml])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:ext_config]).to eq('custom.yaml')
    end

    it 'sets port when -p PORT is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-p 9090])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:port]).to eq('9090')
    end

    it 'sets ws_port when -w WS_PORT is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-w 61985])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:ws_port]).to eq('61985')
    end

    it 'sets update_disabled when -d is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-d])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:update_disabled]).to be true
    end

    it 'sets update_auto when -u is given' do
      original_argv = ARGV.dup
      ARGV.replace(%w[-u])
      result = described_class.parse
      ARGV.replace(original_argv)
      expect(result[:update_auto]).to be true
    end

    it 'returns cached options on second parse' do
      original_argv = ARGV.dup
      ARGV.replace([])
      first = described_class.parse
      ARGV.replace(%w[-v -x])
      second = described_class.parse
      ARGV.replace(original_argv)
      expect(second).to eq(first)
      expect(second[:verbose]).to be false
    end

    it 'prints and exits on invalid option' do
      original_argv = ARGV.dup
      ARGV.replace(%w[--invalid-option])
      allow(Kernel).to receive(:puts).with(/Invalid command line option/)
      allow(Kernel).to receive(:exit).with(1) { raise SystemExit.new(1) }
      expect { described_class.parse }.to raise_error(SystemExit)
      ARGV.replace(original_argv)
    end
  end
end
