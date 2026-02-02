#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_get_variable/module'

RSpec.describe Test_get_variable do
  describe '.options' do
    it 'returns payload_name option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.size).to eq(1)
      expect(opts.first).to include('name' => 'payload_name', 'ui_label' => 'Payload Name', 'value' => 'message')
    end
  end
end
