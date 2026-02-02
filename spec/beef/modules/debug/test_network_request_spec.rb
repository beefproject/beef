#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_network_request/module'

RSpec.describe Test_network_request do
  before do
    config = instance_double(BeEF::Core::Configuration)
    allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
    allow(config).to receive(:beef_host).and_return('127.0.0.1')
    allow(config).to receive(:beef_port).and_return('3000')
    allow(config).to receive(:get).with('beef.http.hook_file').and_return('/hook.js')
  end

  describe '.options' do
    it 'returns scheme, method, domain, port, path, anchor, data, timeout, dataType' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.size).to eq(9)
      names = opts.map { |o| o['name'] }
      expect(names).to include('scheme', 'method', 'domain', 'port', 'path', 'anchor', 'data', 'timeout', 'dataType')
      expect(opts.find { |o| o['name'] == 'domain' }['value']).to eq('127.0.0.1')
      expect(opts.find { |o| o['name'] == 'port' }['value']).to eq('3000')
      expect(opts.find { |o| o['name'] == 'path' }['value']).to eq('/hook.js')
    end
  end

  describe '#post_execute' do
    it 'saves response from datastore' do
      instance = build_command_instance(described_class, 'response' => 'ok')
      results = run_post_execute(instance)
      expect(results).to eq('response' => 'ok')
    end
  end
end
