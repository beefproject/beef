#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Filters do
  describe '.is_non_empty_string?' do
    it 'nil' do
      expect(BeEF::Filters.is_non_empty_string?(nil)).to be(false)
    end

    it 'Integer' do
      expect(BeEF::Filters.is_non_empty_string?(1)).to be(false)
    end

    it 'Empty String' do
      expect(BeEF::Filters.is_non_empty_string?('')).to be(false)
    end

    it 'null' do
      expect(BeEF::Filters.is_non_empty_string?("\x00")).to be(true)
    end

    it 'First char is num' do
      expect(BeEF::Filters.is_non_empty_string?('0')).to be(true)
    end

    it 'First char is alpha' do
      expect(BeEF::Filters.is_non_empty_string?('A')).to be(true)
    end

    it 'Four num chars' do
      expect(BeEF::Filters.is_non_empty_string?('3333')).to be(true)
    end

    it 'Four num chars begining with alpha' do
      expect(BeEF::Filters.is_non_empty_string?('A3333')).to be(true)
    end

    it 'Four num chars begining with null' do
      expect(BeEF::Filters.is_non_empty_string?("\x003333")).to be(true)
    end
  end

  describe '.only?' do
    it 'success' do
      expect(BeEF::Filters.only?('A', 'A')).to be(true)
    end

    it 'fail' do
      expect(BeEF::Filters.only?('A', 'B')).to be(false)
    end
  end

  describe '.exists?' do
    it 'success' do
      expect(BeEF::Filters.exists?('A', 'A')).to be(true)
    end

    it 'fail' do
      expect(BeEF::Filters.exists?('A', 'B')).to be(false)
    end
  end

  describe '.has_null?' do
    context 'false with' do
      it 'general' do
        chars = [nil, '', "\x01", "\xFF", 'A', 'A3333', '0', '}', '.', '+', '-', '-1', '0.A', '3333', '33 33', ' AAAAA', 'AAAAAA ']
        chars.each do |c|
          expect(BeEF::Filters.has_null?(c)).to be(false)
        end
      end

      it 'alphabet' do
        (1..255).each do |c|
          str = ''
          str.concat(c)
          expect(BeEF::Filters.has_null?(str)).to be(false)
        end
      end
    end

    context 'true with' do
      it 'general' do
        chars = ["\x00", "A\x00", "AAAAAA\x00", "\x00A", "\x00AAAAAAAA", "A\x00A", "AAAAA\x00AAAA", "A\n\r\x00", "\x00\n\rA", "A\n\r\x00\n\rA", "\tA\x00A"]
        chars.each do |c|
          expect(BeEF::Filters.has_null?(c)).to be(true)
        end
      end

      it 'alphabet null after' do
        (1..255).each do |c|
          str = ''
          str.concat(c)
          str += "\x00"
          expect(BeEF::Filters.has_null?(str)).to be(true)
        end
      end

      it 'alphabet null before' do
        (1..255).each do |c|
          str = "\x00"
          str.concat(c)
          expect(BeEF::Filters.has_null?(str)).to be(true)
        end
      end
    end
  end

  describe '.has_non_printable_char?' do
    context 'false with' do
      it 'general' do
        chars = [nil, '', 'A', 'A3333', '0', '}', '.', '+', '-', '-1', '0.A', '3333', ' 0AAAAA', ' 0AAA ']
        chars.each do |c|
          expect(BeEF::Filters.has_non_printable_char?(c)).to be(false)
        end
      end

      it 'lowercase' do
        ('a'..'z').each do |c|
          expect(BeEF::Filters.has_non_printable_char?(c)).to be(false)
        end
      end

      it 'uppercase' do
        ('A'..'Z').each do |c|
          expect(BeEF::Filters.has_non_printable_char?(c)).to be(false)
        end
      end

      it 'numbers' do
        ('0'..'9').each do |c|
          expect(BeEF::Filters.has_non_printable_char?(c)).to be(false)
        end
      end
    end

    context 'true with' do
      it 'general' do
        chars = ["\x00", "\x01", "\x02", "A\x03", "\x04A", "\x0033333", "\x00AAAAAA", " AAAAA\x00", "\t\x00AAAAA", "\n\x00AAAAA", "\n\r\x00AAAAAAAAA", "AAAAAAA\x00AAAAAAA",
                 "\n\x00"]
        chars.each do |c|
          expect(BeEF::Filters.has_non_printable_char?(c)).to be(true)
        end
      end

      it 'alphabet null before' do
        (1..255).each do |c|
          str = ''
          str.concat(c)
          str += "\x00"
          expect(BeEF::Filters.has_non_printable_char?(str)).to be(true)
        end
      end
    end
  end

  describe '.nums_only?' do
    it 'false with general' do
      chars = [nil, 1, '', 'A', 'A3333', "\x003333", '}', '.', '+', '-', '-1']
      chars.each do |c|
        expect(BeEF::Filters.nums_only?(c)).to be(false)
      end
    end

    it 'true with general' do
      chars = %w[0 333]
      chars.each do |c|
        expect(BeEF::Filters.nums_only?(c)).to be(true)
      end
    end
  end

  describe '.is_valid_float?' do
    it 'false with general' do
      chars = [nil, 1, '', 'A', 'A3333', "\x003333", '}', '.', '+', '-', '-1', '0', '333', '0.A']
      chars.each do |c|
        expect(BeEF::Filters.is_valid_float?(c)).to be(false)
      end
    end

    it 'true with general' do
      chars = ['33.33', '0.0', '1.0', '0.1']
      chars.each do |c|
        expect(BeEF::Filters.is_valid_float?(c)).to be(true)
      end
    end
  end

  describe '.hexs_only?' do
    it 'false with general' do
      chars = [nil, 1, '', "\x003333", '}', '.', '+', '-', '-1', '0.A', '33.33', '0.0', '1.0', '0.1']
      chars.each do |c|
        expect(BeEF::Filters.hexs_only?(c)).to be(false)
      end
    end

    it 'true with general' do
      chars = %w[0123456789ABCDEFabcdef 0 333 A33333 A]
      chars.each do |c|
        expect(BeEF::Filters.hexs_only?(c)).to be(true)
      end
    end
  end

  describe '.first_char_is_num?' do
    it 'false with general' do
      chars = ['', 'A', 'A33333', "\x0033333"]
      chars.each do |c|
        expect(BeEF::Filters.first_char_is_num?(c)).to be(false)
      end
    end

    it 'true with general' do
      chars = %w[333 0AAAAAA 0]
      chars.each do |c|
        expect(BeEF::Filters.first_char_is_num?(c)).to be(true)
      end
    end
  end

  describe '.has_whitespace_char?' do
    it 'false with general' do
      chars = ['', 'A', 'A33333', "\x0033333", '0', '}', '.', '+', '-', '-1', '0.A']
      chars.each do |c|
        expect(BeEF::Filters.has_whitespace_char?(c)).to be(false)
      end
    end

    it 'true with general' do
      chars = ['33 33', '    ', '                ', ' 0AAAAAAA', ' 0AAAAAAA ', "\t0AAAAAAA", "\n0AAAAAAAA"]
      chars.each do |c|
        expect(BeEF::Filters.has_whitespace_char?(c)).to be(true)
      end
    end
  end

  describe '.alphanums_only?' do
    context 'false with' do
      it 'general' do
        chars = [nil, '', "\n", "\r", "\x01", '}', '.', '+', '-', '-1', 'ee-!@$%^&*}=0.A', '33 33', ' AAAA', 'AAA ']
        chars.each do |c|
          expect(BeEF::Filters.alphanums_only?(c)).to be(false)
        end
      end

      it 'additional nulls' do
        chars = ["\x00", "A\x00", "AAAAAAAAA\x00", "\x00A", "\x00AAAAAAAAA", "A\x00A", "AAAAAAAA\x00AAAAAAAA", "A\n\r\x00", "\x00\n\rA", "A\n\r\x00\n\rA", "\tA\x00A"]
        chars.each do |c|
          expect(BeEF::Filters.alphanums_only?(c)).to be(false)
        end
      end

      it 'alphabet null after' do
        (1..255).each do |c|
          str = ''
          str.concat(c)
          str += "\x00"
          expect(BeEF::Filters.alphanums_only?(str)).to be(false)
        end
      end

      it 'alphabet null before' do
        (1..255).each do |c|
          str = "\x00"
          str.concat(c)
          expect(BeEF::Filters.alphanums_only?(str)).to be(false)
        end
      end

      it 'alphabet around null' do
        (1..255).each do |c|
          str = ''
          str.concat(c)
          str += "\x00"
          str.concat(c)
          expect(BeEF::Filters.alphanums_only?(str)).to be(false)
        end
      end
    end

    context 'true with' do
      it 'general' do
        chars = %w[A A3333 0 3333]
        chars.each do |c|
          expect(BeEF::Filters.alphanums_only?(c)).to be(true)
        end
      end

      it 'uppercase' do
        ('A'..'Z').each do |c|
          expect(BeEF::Filters.alphanums_only?(c)).to be(true)
        end
      end

      it 'lowercase' do
        ('a'..'z').each do |c|
          expect(BeEF::Filters.alphanums_only?(c)).to be(true)
        end
      end

      it 'numbers' do
        ('0'..'9').each do |c|
          expect(BeEF::Filters.alphanums_only?(c)).to be(true)
        end
      end
    end
  end
end
