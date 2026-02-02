#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/link_rewrite_tel/module'

RSpec.describe Link_rewrite_tel do
  describe '.options' do
    it 'returns tel_number option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'tel_number', 'ui_label' => 'Number')
    end
  end

  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'ok')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'ok')
    end
  end
end
