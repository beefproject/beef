#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/mobilesafari_address_spoofing/module'

RSpec.describe Mobilesafari_address_spoofing do
  describe '.options' do
    it 'returns fake_url, real_url, domselectah options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to include('fake_url', 'real_url', 'domselectah')
    end
  end

  describe '#post_execute' do
    it 'saves results and query from datastore' do
      instance = build_command_instance(described_class, 'results' => 'x', 'query' => 'y')
      results = run_post_execute(instance)
      expect(results).to include('results' => 'x', 'query' => 'y')
    end
  end
end
