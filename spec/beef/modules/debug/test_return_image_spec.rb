#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_return_image/module'

RSpec.describe Test_return_image do
  describe '#post_execute' do
    it 'saves image from datastore' do
      instance = build_command_instance(described_class, 'image' => 'base64data')
      results = run_post_execute(instance)
      expect(results).to eq('image' => 'base64data')
    end
  end
end
