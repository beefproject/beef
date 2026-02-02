#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/chrome_extensions/inject_beef/module'

RSpec.describe Inject_beef do
  describe '#post_execute' do
    it 'saves Return from datastore' do
      instance = build_command_instance(described_class, 'return' => 'injected')
      results = run_post_execute(instance)
      expect(results).to eq('Return' => 'injected')
    end
  end
end
