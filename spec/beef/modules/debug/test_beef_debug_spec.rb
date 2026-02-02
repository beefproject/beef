#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_beef_debug/module'

RSpec.describe Test_beef_debug do
  describe '.options' do
    it 'returns an array of option hashes' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.size).to eq(1)
      expect(opts.first).to include('name' => 'msg', 'ui_label' => 'Debug Message')
      expect(opts.first['value']).to include('beef.debug()')
    end
  end

  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'debug output')
      results = run_post_execute(instance)
      expect(results).to eq('Result' => 'debug output')
    end
  end
end
