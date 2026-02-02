#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/get_visited_domains/module'

RSpec.describe Get_visited_domains do
  describe '.options' do
    it 'returns domains option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.size).to eq(1)
      expect(opts.first['name']).to eq('domains')
      expect(opts.first['ui_label']).to eq('Specify custom page to check')
    end
  end

  describe '#post_execute' do
    it 'saves results from datastore' do
      instance = build_command_instance(described_class, 'results' => 'domain1.com, domain2.com')
      results = run_post_execute(instance)
      expect(results).to eq('results' => 'domain1.com, domain2.com')
    end
  end
end
