#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'String colorization' do
  it 'includes Term::ANSIColor module' do
    expect(String.included_modules).to include(Term::ANSIColor)
  end

  it 'can use color methods on strings' do
    string = 'test'
    expect(string.respond_to?(:red)).to be(true)
    expect(string.respond_to?(:green)).to be(true)
    expect(string.respond_to?(:blue)).to be(true)
  end

  it 'applies color methods correctly' do
    string = 'hello'
    colored = string.red

    expect(colored).to be_a(String)
    expect(colored).not_to eq(string) # should now be: "\e[31mhello\e[0m" (red colored hello)
  end
end
