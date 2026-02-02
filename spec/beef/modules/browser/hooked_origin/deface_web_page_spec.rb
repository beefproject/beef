#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/deface_web_page/module'

RSpec.describe Deface_web_page do
  describe '.options' do
    it 'returns deface options with beef base host' do
      config = instance_double(BeEF::Core::Configuration)
      allow(BeEF::Core::Configuration).to receive(:instance).and_return(config)
      allow(config).to receive(:beef_proto).and_return('https')
      allow(config).to receive(:beef_host).and_return('beef.example')
      allow(config).to receive(:beef_port).and_return('3000')

      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to include('deface_title', 'deface_favicon', 'deface_content')
      expect(opts.find { |o| o['name'] == 'deface_favicon' }['value']).to include('https://beef.example:3000')
    end
  end

  describe '#post_execute' do
    it 'saves Result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'deface done')
      results = run_post_execute(instance)
      expect(results).to eq('Result' => 'deface done')
    end
  end
end
