#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_unity/module'

RSpec.describe Detect_unity do
  describe '#post_execute' do
    it 'saves unity from datastore' do
      instance = build_command_instance(described_class, 'unity' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('unity' => 'Yes')
    end
  end
end
