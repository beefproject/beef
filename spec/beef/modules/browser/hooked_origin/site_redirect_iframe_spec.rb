#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/site_redirect_iframe/module'

RSpec.describe Site_redirect_iframe do
  describe '.options' do
    it 'returns iframe options with beef base host' do
      config = instance_double(BeEF::Core::Configuration)
      allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
      allow(config).to receive(:beef_proto).and_return('http')
      allow(config).to receive(:beef_host).and_return('localhost')
      allow(config).to receive(:beef_port).and_return('3000')

      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to include('iframe_title', 'iframe_favicon', 'iframe_src', 'iframe_timeout')
      expect(opts.find { |o| o['name'] == 'iframe_favicon' }['value']).to include('http://localhost:3000')
    end
  end

  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'done')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'done')
    end
  end
end
