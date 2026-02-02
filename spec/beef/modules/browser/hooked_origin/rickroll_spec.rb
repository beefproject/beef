#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/rickroll/module'

RSpec.describe Rickroll do
  describe '#post_execute' do
    it 'saves Result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'played')
      results = run_post_execute(instance)
      expect(results).to eq('Result' => 'played')
    end
  end
end
