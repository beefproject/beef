#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_simple_adblock/module'

RSpec.describe Detect_simple_adblock do
  describe '#post_execute' do
    it 'saves simple_adblock from datastore' do
      instance = build_command_instance(described_class, 'simple_adblock' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('simple_adblock' => 'Yes')
    end

    it 'does not set key when simple_adblock is nil' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to eq({})
    end
  end
end
