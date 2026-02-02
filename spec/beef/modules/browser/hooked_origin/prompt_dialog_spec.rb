#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/prompt_dialog/module'

RSpec.describe Prompt_dialog do
  describe '.options' do
    it 'returns question option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'question', 'ui_label' => 'Prompt text')
    end
  end

  describe '#post_execute' do
    it 'saves answer from datastore' do
      instance = build_command_instance(described_class, 'answer' => 'user input')
      results = run_post_execute(instance)
      expect(results).to eq('answer' => 'user input')
    end
  end
end
