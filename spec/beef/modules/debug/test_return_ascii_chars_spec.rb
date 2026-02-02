#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_return_ascii_chars/module'

RSpec.describe Test_return_ascii_chars do
  describe '#post_execute' do
    it 'saves result_string from datastore' do
      instance = build_command_instance(described_class, 'result_string' => 'ascii data')
      results = run_post_execute(instance)
      expect(results).to eq('Result String' => 'ascii data')
    end
  end
end
