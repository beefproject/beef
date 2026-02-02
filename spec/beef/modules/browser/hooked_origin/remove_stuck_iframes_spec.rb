#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/remove_stuck_iframes/module'

RSpec.describe Remove_stuck_iframes do
  describe '#post_execute' do
    it 'saves head, body, and iframe_ from datastore' do
      instance = build_command_instance(described_class,
                                        'head' => '<title>Test</title>',
                                        'body' => '<p>Body</p>',
                                        'iframe_' => '<iframe></iframe>')
      results = run_post_execute(instance)
      expect(results).to eq('head' => '<title>Test</title>', 'body' => '<p>Body</p>', 'iframe_' => '<iframe></iframe>')
    end
  end
end
