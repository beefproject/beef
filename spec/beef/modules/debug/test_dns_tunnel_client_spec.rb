#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_dns_tunnel_client/module'

RSpec.describe Test_dns_tunnel_client do
  before do
    config = instance_double(BeEF::Core::Configuration)
    allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
  end

  describe '.options' do
    it 'returns domain and data options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.size).to eq(2)
      expect(opts.map { |o| o['name'] }).to contain_exactly('domain', 'data')
      expect(opts.find { |o| o['name'] == 'domain' }['value']).to eq('browserhacker.com')
      expect(opts.find { |o| o['name'] == 'data' }['value']).to include('Lorem ipsum')
    end
  end

  describe '#post_execute' do
    it 'saves dns_requests from datastore' do
      instance = build_command_instance(described_class, 'dns_requests' => 'request log')
      results = run_post_execute(instance)
      expect(results).to eq('dns_requests' => 'request log')
    end
  end
end
