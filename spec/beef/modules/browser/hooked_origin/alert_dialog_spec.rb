#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/alert_dialog/module'

RSpec.describe Alert_dialog do
  describe '.options' do
    it 'returns text textarea option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'text', 'ui_label' => 'Alert text')
    end
  end

  describe '#post_execute' do
    it 'saves User Response message' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to include('User Response' => "The user clicked the 'OK' button when presented with an alert box.")
    end
  end
end
