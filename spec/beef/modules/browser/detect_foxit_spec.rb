#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_foxit/module'

RSpec.describe Detect_foxit do
  describe '#post_execute' do
    it 'saves foxit from datastore' do
      instance = build_command_instance(described_class, 'foxit' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('foxit' => 'Yes')
    end

    it 'calls BrowserDetails.set when results matches foxit=(Yes|No)' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
      instance = build_command_instance(described_class,
                                        'foxit' => 'Yes',
                                        'beefhook' => 'hook123',
                                        'results' => 'foxit=Yes')
      run_post_execute(instance)
      expect(BeEF::Core::Models::BrowserDetails).to have_received(:set).with('hook123', 'HasFoxit', 'Yes')
    end

    it 'does not call BrowserDetails.set when results does not match' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
      instance = build_command_instance(described_class,
                                        'foxit' => 'Yes',
                                        'beefhook' => 'hook123',
                                        'results' => 'unknown')
      run_post_execute(instance)
      expect(BeEF::Core::Models::BrowserDetails).not_to have_received(:set)
    end
  end
end
