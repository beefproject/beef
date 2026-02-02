#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_popup_blocker/module'

RSpec.describe Detect_popup_blocker do
  describe '#post_execute' do
    it 'saves popup_blocker_enabled from datastore' do
      instance = build_command_instance(described_class, 'popup_blocker_enabled' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('popup_blocker_enabled' => 'Yes')
    end
  end
end
