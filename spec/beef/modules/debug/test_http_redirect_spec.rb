#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/debug/test_http_redirect/module'

RSpec.describe Test_http_redirect do
  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'redirect done')
      results = run_post_execute(instance)
      expect(results).to eq('Result' => 'redirect done')
    end
  end

  describe '#pre_send' do
    it 'binds redirect via AssetHandler' do
      instance = described_class.allocate
      handler = instance_double(BeEF::Core::NetworkStack::Handlers::AssetHandler)
      allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
      expect(handler).to receive(:bind_redirect).with('https://beefproject.com', '/redirect')
      instance.pre_send
    end
  end
end
