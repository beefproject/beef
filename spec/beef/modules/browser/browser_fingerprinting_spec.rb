#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/browser_fingerprinting/module'

RSpec.describe Browser_fingerprinting do
  describe '#post_execute' do
    it 'saves browser_type and browser_version from datastore' do
      instance = build_command_instance(described_class,
                                        'browser_type' => 'Chrome',
                                        'browser_version' => '120')
      results = run_post_execute(instance)
      expect(results).to include('browser_type' => 'Chrome', 'browser_version' => '120')
    end

    it 'sets fail message when content is empty' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to eq('fail' => 'Failed to fingerprint browser.')
    end
  end
end
