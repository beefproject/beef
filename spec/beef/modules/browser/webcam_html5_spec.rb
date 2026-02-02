#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/webcam_html5/module'

RSpec.describe Webcam_html5 do
  describe '.options' do
    it 'returns choice combobox option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'choice', 'type' => 'combobox')
    end
  end

  describe '#post_execute' do
    it 'saves result and image from datastore' do
      instance = build_command_instance(described_class, 'result' => 'ok', 'image' => 'data:image/png;base64,abc')
      results = run_post_execute(instance)
      expect(results).to eq('result' => 'ok', 'image' => 'data:image/png;base64,abc')
    end

    it 'omits nil keys' do
      instance = build_command_instance(described_class, {})
      results = run_post_execute(instance)
      expect(results).to eq({})
    end
  end
end
