#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_wmp/module'

RSpec.describe Detect_wmp do
  describe '#post_execute' do
    it 'saves wmp from datastore' do
      instance = build_command_instance(described_class, 'wmp' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('wmp' => 'Yes')
    end

    it 'calls BrowserDetails.set when results matches wmp=(Yes|No)' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
      instance = build_command_instance(described_class,
                                        'wmp' => 'No',
                                        'beefhook' => 'hook1',
                                        'results' => 'wmp=No')
      run_post_execute(instance)
      expect(BeEF::Core::Models::BrowserDetails).to have_received(:set).with('hook1', 'browser.capabilities.wmp', 'No')
    end
  end
end
