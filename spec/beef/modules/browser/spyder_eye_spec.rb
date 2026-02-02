#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/spyder_eye/module'

RSpec.describe Spyder_eye do
  describe '.options' do
    it 'returns repeat and delay options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to contain_exactly('repeat', 'delay')
    end
  end

  describe '#post_execute' do
    it 'saves results from datastore and unbinds asset' do
      handler = instance_double('AssetHandler')
      allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
      allow(handler).to receive(:unbind)
      allow(BeEF::Core::Models::BrowserDetails).to receive(:get).and_return('127.0.0.1')
      allow(File).to receive(:open).and_yield(StringIO.new)

      instance = build_command_instance(described_class,
                                        'results' => 'image=data:image/png;base64,iVBORw0KGgo=',
                                        'beefhook' => 'hook1',
                                        'cid' => '1')
      allow(instance).to receive(:print_info)
      allow(instance).to receive(:print_error)
      allow(BeEF::Core::Logger.instance).to receive(:register)

      results = run_post_execute(instance)

      expect(results).to eq('results' => 'image=data:image/png;base64,iVBORw0KGgo=')
      expect(handler).to have_received(:unbind).with('/h2c.js')
    end
  end
end
