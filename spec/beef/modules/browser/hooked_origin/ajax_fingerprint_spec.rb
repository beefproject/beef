#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/ajax_fingerprint/module'

RSpec.describe Ajax_fingerprint do
  describe '#post_execute' do
    it 'saves script_urls from datastore' do
      instance = build_command_instance(described_class, 'script_urls' => ['/a.js', '/b.js'])
      results = run_post_execute(instance)
      expect(results).to include('script_urls' => ['/a.js', '/b.js'])
    end

    it 'sets fail when content is empty' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to include('fail' => 'Failed to fingerprint ajax.')
    end
  end
end
