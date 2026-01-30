#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Filters do
  describe '.is_valid_hostname?' do
    it 'validates hostnames correctly' do
      expect(BeEF::Filters.is_valid_hostname?('example.com')).to be(true)
      expect(BeEF::Filters.is_valid_hostname?('sub.example.com')).to be(true)
      expect(BeEF::Filters.is_valid_hostname?('a' * 256)).to be(false) # too long
      expect(BeEF::Filters.is_valid_hostname?('')).to be(false)
      expect(BeEF::Filters.is_valid_hostname?(nil)).to be(false)
    end
  end

  describe '.is_valid_verb?' do
    it 'validates HTTP verbs' do
      %w[HEAD GET POST OPTIONS PUT DELETE].each do |verb|
        expect(BeEF::Filters.is_valid_verb?(verb)).to be(true)
      end
      expect(BeEF::Filters.is_valid_verb?('INVALID')).to be(false)
    end
  end

  describe '.is_valid_url?' do
    it 'validates URLs' do
      expect(BeEF::Filters.is_valid_url?(nil)).to be(false)
      expect(BeEF::Filters.is_valid_url?('http://example.com')).to be(true)
    end
  end

  describe '.is_valid_http_version?' do
    it 'validates HTTP versions' do
      expect(BeEF::Filters.is_valid_http_version?('HTTP/1.0')).to be(true)
      expect(BeEF::Filters.is_valid_http_version?('HTTP/1.1')).to be(true)
      expect(BeEF::Filters.is_valid_http_version?('HTTP/2.0')).to be(false)
    end
  end

  describe '.is_valid_host_str?' do
    it 'validates host header strings' do
      expect(BeEF::Filters.is_valid_host_str?('Host:')).to be(true)
      host_str = "Host:\r".dup
      expect(BeEF::Filters.is_valid_host_str?(host_str)).to be(true)
      expect(BeEF::Filters.is_valid_host_str?('Invalid')).to be(false)
    end
  end
end
