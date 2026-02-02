#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/get_page_html/module'

RSpec.describe Get_page_html do
  describe '#post_execute' do
    it 'saves head and body from datastore' do
      instance = build_command_instance(described_class, 'head' => '<title>Test</title>', 'body' => '<p>Hello</p>')
      results = run_post_execute(instance)
      expect(results).to eq('head' => '<title>Test</title>', 'body' => '<p>Hello</p>')
    end
  end
end
