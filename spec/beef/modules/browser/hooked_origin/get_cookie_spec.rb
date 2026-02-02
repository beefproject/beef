#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/get_cookie/module'

RSpec.describe Get_cookie do
  describe '#post_execute' do
    it 'saves cookie from datastore' do
      instance = build_command_instance(described_class, 'cookie' => 'session=abc123')
      results = run_post_execute(instance)
      expect(results).to eq('cookie' => 'session=abc123')
    end
  end
end
