#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/get_autocomplete_creds/module'

RSpec.describe Get_autocomplete_creds do
  describe '.options' do
    it 'returns empty array' do
      expect(described_class.options).to eq([])
    end
  end

  describe '#post_execute' do
    it 'saves results from datastore' do
      instance = build_command_instance(described_class, 'results' => [{ 'user' => 'a', 'pass' => 'b' }])
      results = run_post_execute(instance)
      expect(results).to eq('results' => [{ 'user' => 'a', 'pass' => 'b' }])
    end
  end
end
