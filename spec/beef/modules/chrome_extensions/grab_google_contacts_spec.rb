#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/chrome_extensions/grab_google_contacts/module'

RSpec.describe Grab_google_contacts do
  describe '#post_execute' do
    it 'saves Return from datastore' do
      instance = build_command_instance(described_class, 'return' => 'contacts data')
      results = run_post_execute(instance)
      expect(results).to eq('Return' => 'contacts data')
    end
  end
end
