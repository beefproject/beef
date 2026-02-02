#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/site_redirect/module'

RSpec.describe Site_redirect do
  describe '.options' do
    it 'returns redirect_url option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'redirect_url', 'ui_label' => 'Redirect URL')
    end
  end

  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'redirected')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'redirected')
    end
  end
end
