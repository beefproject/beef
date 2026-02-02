#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/get_local_storage/module'

RSpec.describe Get_local_storage do
  describe '#post_execute' do
    it 'saves localStorage from datastore' do
      instance = build_command_instance(described_class, 'localStorage' => 'key=value')
      results = run_post_execute(instance)
      expect(results).to eq('localStorage' => 'key=value')
    end
  end
end
