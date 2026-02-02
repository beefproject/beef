#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_unsafe_activex/module'

RSpec.describe Detect_unsafe_activex do
  describe '#post_execute' do
    it 'saves unsafe_activex from datastore' do
      instance = build_command_instance(described_class, 'unsafe_activex' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('unsafe_activex' => 'Yes')
    end
  end
end
