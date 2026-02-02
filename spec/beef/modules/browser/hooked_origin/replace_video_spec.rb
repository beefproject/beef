#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/replace_video/module'

RSpec.describe Replace_video do
  describe '.options' do
    it 'returns youtube_id and jquery_selector options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to contain_exactly('youtube_id', 'jquery_selector')
    end
  end

  describe '#post_execute' do
    it 'saves Result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'replaced')
      results = run_post_execute(instance)
      expect(results).to eq('Result' => 'replaced')
    end
  end
end
