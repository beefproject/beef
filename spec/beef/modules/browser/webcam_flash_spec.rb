#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/webcam_flash/module'

RSpec.describe Webcam_flash do
  describe '.options' do
    it 'returns social_engineering and picture options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to include('social_engineering_title', 'no_of_pictures', 'interval')
    end
  end

  describe '#post_execute' do
    it 'saves result and picture from datastore and unbinds assets' do
      handler = instance_double('AssetHandler')
      allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
      allow(handler).to receive(:unbind)

      instance = build_command_instance(described_class, 'result' => 'ok', 'picture' => 'base64data')
      results = run_post_execute(instance)

      expect(results).to eq('result' => 'ok', 'picture' => 'base64data')
      expect(handler).to have_received(:unbind).with('/takeit.swf')
      expect(handler).to have_received(:unbind).with('/swfobject.js')
    end
  end
end
