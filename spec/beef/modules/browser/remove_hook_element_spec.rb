#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/remove_hook_element/module'

RSpec.describe Remove_hook_element do
  describe '#post_execute' do
    it 'saves result from datastore when present' do
      instance = build_command_instance(described_class, 'result' => 'removed')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'removed')
    end

    it 'saves empty content when result is nil' do
      instance = build_command_instance(described_class, 'result' => nil)
      results = run_post_execute(instance)
      expect(results).to eq({})
    end
  end
end
