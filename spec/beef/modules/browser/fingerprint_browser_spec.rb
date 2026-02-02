#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/fingerprint_browser/module'

RSpec.describe Fingerprint_browser do
  describe '#post_execute' do
    it 'saves fingerprint and components from datastore' do
      instance = build_command_instance(described_class,
                                        'fingerprint' => 'abc123',
                                        'components' => '[]')
      results = run_post_execute(instance)
      expect(results).to include('fingerprint' => 'abc123', 'components' => '[]')
    end

    it 'sets fail message when content is empty' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to eq('fail' => 'Failed to fingerprint browser.')
    end
  end
end
