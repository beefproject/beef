#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_quicktime/module'

RSpec.describe Detect_quicktime do
  describe '#post_execute' do
    it 'saves quicktime from datastore' do
      instance = build_command_instance(described_class, 'quicktime' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('quicktime' => 'Yes')
    end
  end
end
