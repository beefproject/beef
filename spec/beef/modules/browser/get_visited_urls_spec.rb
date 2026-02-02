#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/get_visited_urls/module'

RSpec.describe Get_visited_urls do
  describe '.options' do
    it 'returns url textarea option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'urls', 'type' => 'textarea', 'ui_label' => 'URL(s)')
    end
  end

  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'https://example.com')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'https://example.com')
    end
  end
end
