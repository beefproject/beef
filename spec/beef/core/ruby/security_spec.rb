#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'Security method overrides' do
  it 'overrides exec method' do
    # The exec method should be overridden to prevent usage
    # We can't easily test the exit behavior without forking
    # so we just check that the method is overridden
    expect(method(:exec).source_location).not_to be_nil
    expect(method(:exec).source_location[0]).to include('core/ruby/security.rb')
  end

  it 'overrides system method' do
    # The system method should be overridden
    expect(method(:system).source_location).not_to be_nil
    expect(method(:system).source_location[0]).to include('core/ruby/security.rb')
  end

  it 'overrides Kernel.system method' do
    # Kernel.system should be overridden
    expect(Kernel.method(:system).source_location).not_to be_nil
    expect(Kernel.method(:system).source_location[0]).to include('core/ruby/security.rb')
  end
end
