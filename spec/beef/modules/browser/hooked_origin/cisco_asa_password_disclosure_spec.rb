#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/cisco_asa_password_disclosure/module'

RSpec.describe Cisco_asa_passwords do
  describe '#post_execute' do
    it 'saves cisco_asa_passwords from datastore' do
      instance = build_command_instance(described_class, 'cisco_asa_passwords' => 'pwd=secret')
      results = run_post_execute(instance)
      expect(results).to eq('cisco_asa_passwords' => 'pwd=secret')
    end
  end
end
