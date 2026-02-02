#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_cors_request/module'

RSpec.describe Test_cors_request do
  describe '.options' do
    it 'returns method, url, and data options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.size).to eq(3)
      expect(opts.map { |o| o['name'] }).to contain_exactly('method', 'url', 'data')
      expect(opts.find { |o| o['name'] == 'method' }['value']).to eq('GET')
      expect(opts.find { |o| o['name'] == 'data' }['value']).to eq('postdata')
    end
  end

  describe '#post_execute' do
    it 'saves response from datastore' do
      instance = build_command_instance(described_class, 'response' => 'cors body')
      results = run_post_execute(instance)
      expect(results).to eq('response' => 'cors body')
    end
  end
end
