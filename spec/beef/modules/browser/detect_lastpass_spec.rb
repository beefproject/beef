#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_lastpass/module'

RSpec.describe Detect_lastpass do
  describe '#post_execute' do
    it 'saves lastpass from datastore' do
      instance = build_command_instance(described_class, 'lastpass' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('lastpass' => 'Yes')
    end

    it 'does not set key when lastpass is nil' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to eq({})
    end
  end
end
