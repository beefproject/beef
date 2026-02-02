#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/deface_web_page_component/module'

RSpec.describe Deface_web_page_component do
  describe '.options' do
    it 'returns deface_selector and deface_content options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to include('deface_selector', 'deface_content')
    end
  end

  describe '#post_execute' do
    it 'saves Result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'done')
      results = run_post_execute(instance)
      expect(results).to eq('Result' => 'done')
    end
  end
end
