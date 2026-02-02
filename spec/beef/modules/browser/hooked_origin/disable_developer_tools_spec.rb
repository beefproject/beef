#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/disable_developer_tools/module'

RSpec.describe Disable_developer_tools do
  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'disabled')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'disabled')
    end
  end
end
