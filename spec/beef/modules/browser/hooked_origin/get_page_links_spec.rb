#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/get_page_links/module'

RSpec.describe Get_page_links do
  describe '#post_execute' do
    it 'saves links from datastore' do
      instance = build_command_instance(described_class, 'links' => '<a href="/">Home</a>')
      results = run_post_execute(instance)
      expect(results).to eq('links' => '<a href="/">Home</a>')
    end
  end
end
