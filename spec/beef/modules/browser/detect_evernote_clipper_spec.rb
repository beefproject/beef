#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_evernote_clipper/module'

RSpec.describe Detect_evernote_clipper do
  describe '#post_execute' do
    it 'saves evernote_clipper from datastore' do
      instance = build_command_instance(described_class, 'evernote_clipper' => 'Yes')
      results = run_post_execute(instance)
      expect(results).to eq('evernote_clipper' => 'Yes')
    end

    it 'does not set key when evernote_clipper is nil' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to eq({})
    end
  end
end
