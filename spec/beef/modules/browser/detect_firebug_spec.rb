#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_firebug/module'

RSpec.describe Detect_firebug do
  describe '#post_execute' do
    it 'saves firebug from datastore when present' do
      instance = build_command_instance(described_class, 'firebug' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('firebug' => 'Yes')
    end

    it 'saves empty content when firebug is nil' do
      instance = build_command_instance(described_class, 'firebug' => nil)
      results = run_post_execute(instance)
      expect(results).to eq({})
    end
  end
end
