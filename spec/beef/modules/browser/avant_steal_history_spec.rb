#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/avant_steal_history/module'

RSpec.describe Avant_steal_history do
  describe '.options' do
    it 'returns cId option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'cId', 'ui_label' => 'Command ID')
    end
  end

  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'done')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'done')
    end
  end
end
