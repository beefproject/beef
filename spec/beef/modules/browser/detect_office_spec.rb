#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_office/module'

RSpec.describe Detect_office do
  describe '#post_execute' do
    it 'saves office from datastore' do
      instance = build_command_instance(described_class, 'office' => 'Office 2016')
      results = run_post_execute(instance)
      expect(results).to eq('office' => 'Office 2016')
    end

    it 'calls BrowserDetails.set when results matches office=Office N' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
      instance = build_command_instance(described_class,
                                        'office' => 'Office 2016',
                                        'beefhook' => 'hook123',
                                        'results' => 'office=Office 2016')
      run_post_execute(instance)
      expect(BeEF::Core::Models::BrowserDetails).to have_received(:set).with('hook123', 'HasOffice', '2016')
    end

    it 'does not call BrowserDetails.set when results does not match' do
      allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
      instance = build_command_instance(described_class,
                                        'office' => 'None',
                                        'beefhook' => 'hook123',
                                        'results' => 'office=None')
      run_post_execute(instance)
      expect(BeEF::Core::Models::BrowserDetails).not_to have_received(:set)
    end
  end
end
