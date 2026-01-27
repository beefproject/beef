#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'spec_helper'

RSpec.describe 'Hash#deep_merge' do
  it 'merges two simple hashes' do
    hash1 = { a: 1, b: 2 }
    hash2 = { c: 3, d: 4 }
    result = hash1.deep_merge(hash2)

    expect(result).to eq({ a: 1, b: 2, c: 3, d: 4 })
  end

  it 'overwrites duplicate keys with values from calling hash' do
    hash1 = { a: 1, b: 2 }
    hash2 = { b: 3, c: 4 }
    result = hash1.deep_merge(hash2)

    expect(result[:a]).to eq(1)
    expect(result[:b]).to eq(3) # hash2 value overwrites
    expect(result[:c]).to eq(4)
  end

  it 'recursively merges nested hashes' do
    hash1 = { a: { b: 1, c: 2 }, d: 3 }
    hash2 = { a: { c: 4, e: 5 }, f: 6 }
    result = hash1.deep_merge(hash2)

    expect(result[:a][:b]).to eq(1)
    expect(result[:a][:c]).to eq(4) # hash2 value overwrites
    expect(result[:a][:e]).to eq(5)
    expect(result[:d]).to eq(3)
    expect(result[:f]).to eq(6)
  end

  it 'handles deeply nested hashes' do
    hash1 = { a: { b: { c: 1 } } }
    hash2 = { a: { b: { d: 2 } } }
    result = hash1.deep_merge(hash2)

    expect(result[:a][:b][:c]).to eq(1)
    expect(result[:a][:b][:d]).to eq(2)
  end

  it 'does not modify the original hash' do
    hash1 = { a: 1 }
    hash2 = { b: 2 }
    original_hash1 = hash1.dup

    hash1.deep_merge(hash2)

    expect(hash1).to eq(original_hash1)
  end

  it 'handles empty hashes' do
    hash1 = {}
    hash2 = { a: 1 }
    result = hash1.deep_merge(hash2)

    expect(result).to eq({ a: 1 })
  end

  it 'handles merging with empty hash' do
    hash1 = { a: 1 }
    hash2 = {}
    result = hash1.deep_merge(hash2)

    expect(result).to eq({ a: 1 })
  end

  it 'handles non-hash values in nested structure' do
    hash1 = { a: { b: 1 } }
    hash2 = { a: 2 } # a is not a hash in hash2
    result = hash1.deep_merge(hash2)

    expect(result[:a]).to eq(2) # Should overwrite with non-hash value
  end

  it 'handles nil values in source hash' do
    hash1 = { a: nil, b: 1 }
    hash2 = { a: 2, c: 3 }
    result = hash1.deep_merge(hash2)

    expect(result[:a]).to eq(2) # Should overwrite nil
    expect(result[:b]).to eq(1)
    expect(result[:c]).to eq(3)
  end

  it 'handles nil values when merging nested hashes' do
    hash1 = { a: nil }
    hash2 = { a: { b: 1 } }
    result = hash1.deep_merge(hash2)

    expect(result[:a]).to eq({ b: 1 }) # Should overwrite nil with hash
  end
end
