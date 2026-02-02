#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/browser/detect_toolbars/module'

RSpec.describe Detect_toolbars do
  describe '#post_execute' do
    it 'saves toolbars from datastore' do
      instance = build_command_instance(described_class, 'toolbars' => 'Toolbar1, Toolbar2')
      results = run_post_execute(instance)
      expect(results).to eq('toolbars' => 'Toolbar1, Toolbar2')
    end
  end
end
