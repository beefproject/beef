#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_return_long_string/module'

RSpec.describe Test_return_long_string do
  describe '.options' do
    it 'returns repeat and repeat_string options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.size).to eq(2)
      names = opts.map { |o| o['name'] }
      expect(names).to contain_exactly('repeat', 'repeat_string')
      expect(opts.find { |o| o['name'] == 'repeat' }['value']).to eq('1024')
      expect(opts.find { |o| o['name'] == 'repeat_string' }['value']).to eq('\u00AE')
    end
  end

  describe '#post_execute' do
    it 'saves result_string from datastore' do
      instance = build_command_instance(described_class, 'result_string' => 'long string')
      results = run_post_execute(instance)
      expect(results).to eq('Result String' => 'long string')
    end
  end
end
