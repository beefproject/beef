#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/webcam_permission_check/module'

RSpec.describe Webcam_permission_check do
  describe '#post_execute' do
    it 'unbinds cameraCheck and swfobject assets' do
      handler = instance_double('AssetHandler')
      allow(BeEF::Core::NetworkStack::Handlers::AssetHandler).to receive(:instance).and_return(handler)
      allow(handler).to receive(:unbind)

      instance = build_command_instance(described_class, {})
      instance.post_execute

      expect(handler).to have_received(:unbind).with('/cameraCheck.swf')
      expect(handler).to have_received(:unbind).with('/swfobject.js')
    end
  end
end
