#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_vlc/module'

RSpec.describe Detect_vlc do
  describe '#post_execute' do
    it 'saves vlc from datastore' do
      instance = build_command_instance(described_class, 'vlc' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('vlc' => 'Yes')
    end

    it 'calls BrowserDetails.set when results matches vlc=(Yes|No)' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
      instance = build_command_instance(described_class,
                                        'vlc' => 'Yes',
                                        'beefhook' => 'hook123',
                                        'results' => 'vlc=Yes')
      run_post_execute(instance)
      expect(BeEF::Core::Models::BrowserDetails).to have_received(:set).with('hook123', 'browser.capabilities.vlc', 'Yes')
    end
  end
end
