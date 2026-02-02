#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/get_session_storage/module'

RSpec.describe Get_session_storage do
  describe '#post_execute' do
    it 'saves sessionStorage from datastore' do
      instance = build_command_instance(described_class, 'sessionStorage' => 'key=value')
      results = run_post_execute(instance)
      expect(results).to eq('sessionStorage' => 'key=value')
    end
  end
end
