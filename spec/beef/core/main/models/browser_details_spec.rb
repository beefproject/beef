#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF BrowserDetails' do

  before(:all) do
    @session = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
  end

  it 'set nil value' do
    BeEF::Core::Models::BrowserDetails.set(@session, 'key_with_nil_value', nil)
    expect(BeEF::Core::Models::BrowserDetails.get(@session, 'key_with_nil_value')).to be_empty
  end

  it 'set value' do
    key_name = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    key_value = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    BeEF::Core::Models::BrowserDetails.set(@session, key_name, key_value)
    expect(BeEF::Core::Models::BrowserDetails.get(@session, key_name)).to eql(key_value)
  end

  it 'update value' do
    key_name = (0...10).map { ('a'..'z').to_a[rand(26)] }.join

    original_key_value = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    BeEF::Core::Models::BrowserDetails.set(@session, key_name, original_key_value).to_s
    expect(BeEF::Core::Models::BrowserDetails.get(@session, key_name)).to eql(original_key_value)

    new_key_value = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    BeEF::Core::Models::BrowserDetails.set(@session, key_name, new_key_value).to_s
    expect(BeEF::Core::Models::BrowserDetails.get(@session, key_name)).to_not eql(original_key_value)
    expect(BeEF::Core::Models::BrowserDetails.get(@session, key_name)).to eql(new_key_value)
  end

end
