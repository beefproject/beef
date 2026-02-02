#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_mime_types/module'

RSpec.describe Detect_mime_types do
  describe '#post_execute' do
    it 'saves mime_types from datastore' do
      instance = build_command_instance(described_class, 'mime_types' => 'application/pdf')
      results = run_post_execute(instance)
      expect(results).to eq('mime_types' => 'application/pdf')
    end

    it 'does not set key when mime_types is nil' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to eq({})
    end
  end
end
