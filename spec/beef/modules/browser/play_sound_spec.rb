#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/play_sound/module'

RSpec.describe Play_sound do
  describe '.options' do
    it 'returns sound_file_uri option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'sound_file_uri', 'ui_label' => 'Sound File Path')
    end
  end

  describe '#post_execute' do
    it 'saves result from datastore' do
      instance = build_command_instance(described_class, 'result' => 'played')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'played')
    end
  end
end
