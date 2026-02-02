#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/get_stored_credentials/module'

RSpec.describe Get_stored_credentials do
  describe '#post_execute' do
    it 'saves form_data from datastore' do
      instance = build_command_instance(described_class, 'form_data' => 'user=admin&pass=secret')
      results = run_post_execute(instance)
      expect(results).to eq('form_data' => 'user=admin&pass=secret')
    end
  end
end
