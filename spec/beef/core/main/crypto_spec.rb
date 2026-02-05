#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'BeEF::Core::Crypto' do
  let(:config) { BeEF::Core::Configuration.instance }

  describe '.secure_token' do
    it 'generates a hex string of the specified length' do
      token = BeEF::Core::Crypto.secure_token(20)
      expect(token).to be_a(String)
      expect(token.length).to eq(40) # 20 bytes = 40 hex chars
      expect(token).to match(/\A[0-9a-f]+\z/)
    end

    it 'uses config default length when no length provided' do
      default_length = config.get('beef.crypto_default_value_length').to_i
      token = BeEF::Core::Crypto.secure_token
      expect(token.length).to eq(default_length * 2) # bytes to hex conversion
    end

    it 'raises TypeError for length below minimum' do
      expect { BeEF::Core::Crypto.secure_token(10) }.to raise_error(TypeError, /minimum length/)
    end

    it 'generates different tokens on each call' do
      token1 = BeEF::Core::Crypto.secure_token(20)
      token2 = BeEF::Core::Crypto.secure_token(20)
      expect(token1).not_to eq(token2)
    end
  end

  describe '.random_alphanum_string' do
    it 'generates a string of the specified length' do
      result = BeEF::Core::Crypto.random_alphanum_string(15)
      expect(result).to be_a(String)
      expect(result.length).to eq(15)
      expect(result).to match(/\A[a-zA-Z0-9]+\z/)
    end

    it 'raises TypeError for invalid inputs' do
      expect { BeEF::Core::Crypto.random_alphanum_string('invalid') }.to raise_error(TypeError)
      expect { BeEF::Core::Crypto.random_alphanum_string(0) }.to raise_error(TypeError, /Invalid length/)
      expect { BeEF::Core::Crypto.random_alphanum_string(-1) }.to raise_error(TypeError, /Invalid length/)
    end
  end

  describe '.random_hex_string' do
    it 'generates a hex string of the specified length' do
      result = BeEF::Core::Crypto.random_hex_string(10)
      expect(result).to be_a(String)
      expect(result.length).to eq(10)
      expect(result).to match(/\A[0-9a-f]+\z/)
    end

    it 'raises TypeError for invalid inputs' do
      expect { BeEF::Core::Crypto.random_hex_string('invalid') }.to raise_error(TypeError)
      expect { BeEF::Core::Crypto.random_hex_string(0) }.to raise_error(TypeError, /Invalid length/)
    end
  end

  # NOTE: .dns_rule_id is not tested here as it requires database queries
  # and is better suited for integration tests
end
