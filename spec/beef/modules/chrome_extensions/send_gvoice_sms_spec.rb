#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require_relative '../../../spec_helper'
require_relative '../../../../modules/chrome_extensions/send_gvoice_sms/module'

RSpec.describe Send_gvoice_sms do
  describe '.options' do
    it 'returns to and message options' do
      opts = described_class.options
      expect(opts).to be_an(Array)
      expect(opts.map { |o| o['name'] }).to include('to', 'message')
    end
  end

  describe '#post_execute' do
    it 'saves To, Message, Status from datastore' do
      instance = build_command_instance(described_class,
                                        'to' => '1234567890',
                                        'message' => 'Hello',
                                        'status' => 'sent')
      results = run_post_execute(instance)
      expect(results).to include('To' => '1234567890', 'Message' => 'Hello', 'Status' => 'sent')
    end
  end
end
