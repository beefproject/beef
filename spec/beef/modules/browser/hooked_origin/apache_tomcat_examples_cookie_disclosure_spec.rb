#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../../spec_helper'
require_relative '../../../../../modules/browser/hooked_origin/apache_tomcat_examples_cookie_disclosure/module'

RSpec.describe Apache_tomcat_examples_cookie_disclosure do
  describe '.options' do
    it 'returns request_header_servlet_path option' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.first).to include('name' => 'request_header_servlet_path')
    end
  end

  describe '#post_execute' do
    it 'saves cookies from datastore' do
      instance = build_command_instance(described_class, 'cookies' => 'session=abc')
      results = run_post_execute(instance)
      expect(results).to eq('cookies' => 'session=abc')
    end
  end
end
