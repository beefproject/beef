#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/chrome_extensions/get_all_cookies/module'

RSpec.describe Get_all_cookies do
  describe '.options' do
    it 'returns url option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'url', 'ui_label' => 'Domain (e.g. http://facebook.com)')
    end
  end

  describe '#post_execute' do
    it 'saves Return from datastore' do
      instance = build_command_instance(described_class, 'return' => 'cookies data')
      results = run_post_execute(instance)
      expect(results).to eq('Return' => 'cookies data')
    end
  end
end
