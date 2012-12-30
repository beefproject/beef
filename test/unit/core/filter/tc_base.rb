#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

require '../../core/filters/base'

class TC_Filter < Test::Unit::TestCase

  def test_is_non_empty_string
    assert((not BeEF::Filters::is_non_empty_string?(nil)), 'Nil string')
    assert((not BeEF::Filters::is_non_empty_string?(1)), 'Is integer')
    assert((not BeEF::Filters::is_non_empty_string?("")), 'Empty string')
    
    assert((BeEF::Filters::is_non_empty_string?("\x00")), 'Single null')
    assert((BeEF::Filters::is_non_empty_string?("0")), 'First char is a num')
    assert((BeEF::Filters::is_non_empty_string?("A")), 'First char is a alpha')
    assert(BeEF::Filters::is_non_empty_string?("3333"), '4 num chars')
    assert((BeEF::Filters::is_non_empty_string?("A3333")), '4 num chars begining with an aplha')
    assert((BeEF::Filters::is_non_empty_string?("\x003333")), '4 num chars begining with a null')
  end
  
  def test_only
    assert((BeEF::Filters::only?('A', 'A')), 'A - A -> success')
    assert((not BeEF::Filters::only?('A', 'B')), 'A - B -> fail')

  end
  
  def test_exists
    
    assert((BeEF::Filters::exists?('A', 'A')), 'A - A -> success')
    assert((not BeEF::Filters::exists?('A', 'B')), 'A - B -> fail')

  end

  def test_has_null
    assert((not BeEF::Filters::has_null?(nil)), 'Nil')
    assert((not BeEF::Filters::has_null?("")), 'Empty string')
    assert((not BeEF::Filters::has_null?("\x01")), '0x01 string')
    assert((not BeEF::Filters::has_null?("\xFF")), '0xFF string')
    assert((not BeEF::Filters::has_null?("A")), 'Single char')
    assert((not BeEF::Filters::has_null?("A3333")), '4 num chars begining with an aplha')
    assert((not BeEF::Filters::has_null?("0")), '0 string')
    assert((not BeEF::Filters::has_null?("}")), '} char')
    assert((not BeEF::Filters::has_null?(".")), '. char')
    assert((not BeEF::Filters::has_null?("+")), '+ char')
    assert((not BeEF::Filters::has_null?("-")), '- char')
    assert((not BeEF::Filters::has_null?("-1")), '-1 string')
    assert((not BeEF::Filters::has_null?("0.A")), '0.A string')
    assert((not BeEF::Filters::has_null?("3333")), '33 33 string')
    assert((not BeEF::Filters::has_null?("33 33")), '33 33 string')
    assert((not BeEF::Filters::has_null?(" AAAAAAAA")), 'white space at start of string')
    assert((not BeEF::Filters::has_null?("AAAAAAAA ")), 'white space at end of string')
    
    (1..255).each {|c| 
      str = ''
      str.concat(c)
      assert(!(BeEF::Filters::has_null?(str)), 'loop of around every char')
    }
      
    assert((BeEF::Filters::has_null?("\x00")), 'Single null')
    assert((BeEF::Filters::has_null?("A\x00")), 'Char and null')
    assert((BeEF::Filters::has_null?("AAAAAAAA\x00")), 'Char and null')
    assert((BeEF::Filters::has_null?("\x00A")), 'Null and char')
    assert((BeEF::Filters::has_null?("\x00AAAAAAAAA")), 'Null and chars')
    assert((BeEF::Filters::has_null?("A\x00A")), 'Null surrounded by chars')
    assert((BeEF::Filters::has_null?("AAAAAAAAA\x00AAAAAAAAA")), 'Null surrounded by chars')
    assert((BeEF::Filters::has_null?("A\n\r\x00")), 'new line and carriage return at start of string')
    assert((BeEF::Filters::has_null?("\x00\n\rA")), 'new line and carriage return at end of string')
    assert((BeEF::Filters::has_null?("A\n\r\x00\n\rA")), 'new line and carriage return at start and end of string')
    assert((BeEF::Filters::has_null?("\tA\x00A")), 'tab at start of string')

    (1..255).each {|c| 
      str = ''
      str.concat(c)
      str += "\x00"
      assert((BeEF::Filters::has_null?(str)), 'loop of behind every char')
    }
    
    (1..255).each {|c| 
      str = ''
      str += "\x00"
      str.concat(c)
      assert((BeEF::Filters::has_null?(str)), 'loop of infront every char')
    }
    
    (1..255).each {|c| 
      str = ''
      str.concat(c)
      str += "\x00"
      str.concat(c)
      assert((BeEF::Filters::has_null?(str)), 'loop of around every char')
    }

  end

  def test_has_non_printable_char
    assert((not BeEF::Filters::has_non_printable_char?(nil)), 'Nil')
    assert((not BeEF::Filters::has_non_printable_char?("")), 'Empty string')
    assert((not BeEF::Filters::has_non_printable_char?("A")), 'Single char')
    assert((not BeEF::Filters::has_non_printable_char?("A3333")), '4 num chars begining with an aplha')
    assert((not BeEF::Filters::has_non_printable_char?("0")), '0 string')
    assert((not BeEF::Filters::has_non_printable_char?("}")), '} char')
    assert((not BeEF::Filters::has_non_printable_char?(".")), '. char')
    assert((not BeEF::Filters::has_non_printable_char?("+")), '+ char')
    assert((not BeEF::Filters::has_non_printable_char?("-")), '- char')
    assert((not BeEF::Filters::has_non_printable_char?("-1")), '-1 string')
    assert((not BeEF::Filters::has_non_printable_char?("0.A")), '0.A string')
    assert((not BeEF::Filters::has_non_printable_char?("3333")), '4 num chars')
    assert((not BeEF::Filters::has_non_printable_char?(" 0AAAAAAAA")), 'white space at start of string')
    assert((not BeEF::Filters::has_non_printable_char?(" 0AAAAAAAA ")), 'white space at end of string')
    
    # check lowercase chars
    ('a'..'z').each {|c| 
      assert((not BeEF::Filters::has_non_printable_char?(c)), 'lowercase chars')
    }
    
    # check uppercase chars
    ('A'..'Z').each {|c| 
      assert((not BeEF::Filters::has_non_printable_char?(c)), 'uppercase chars')
    }
    
    # check numbers chars
    ('0'..'9').each {|c| 
      assert((not BeEF::Filters::has_non_printable_char?(c)), 'number chars')
    }
    
    assert((BeEF::Filters::has_non_printable_char?("\x00")), '0x00 string')
    assert((BeEF::Filters::has_non_printable_char?("\x01")), '0x01 string')
    assert((BeEF::Filters::has_non_printable_char?("\x02")), '0x02 string')
    assert((BeEF::Filters::has_non_printable_char?("\xF0")), '0xFE string')
    assert((BeEF::Filters::has_non_printable_char?("\xFE")), '0xFE string')
    assert((BeEF::Filters::has_non_printable_char?("\xFF")), '0xFF string')
    
    assert((BeEF::Filters::has_non_printable_char?("A\x03")), 'Single char and non printable char')
    assert((BeEF::Filters::has_non_printable_char?("\x04A")), 'Single char and non printable char')
    assert((BeEF::Filters::has_non_printable_char?("\x003333")), '4 num chars begining with a null')
    assert((BeEF::Filters::has_non_printable_char?("\x00AAAAAAAA")), 'null at start of string')
    assert((BeEF::Filters::has_non_printable_char?(" AAAAAAAA\x00")), 'null at end of string')
    assert((BeEF::Filters::has_non_printable_char?("\t\x00AAAAAAAA")), 'tab at start of string')
    assert((BeEF::Filters::has_non_printable_char?("\n\x00AAAAAAAA")), 'new line at start of string')
    assert((BeEF::Filters::has_non_printable_char?("\n\r\x00AAAAAAAA")), 'new line and carriage return at start of string')
    assert((BeEF::Filters::has_non_printable_char?("AAAAAAAAA\x00AAAAA")), 'Chars and null')
    assert((BeEF::Filters::has_non_printable_char?("\n\x00")), 'newline and null')    
    
    
    (0..255).each {|c| 
      str = ''
      str.concat(c)
      str += "\x00"
      str.concat(c)
      assert((BeEF::Filters::has_non_printable_char?(str)), 'loop of around every char')
    }
    
  end
  
  def test_is_nums_only
    assert((not BeEF::Filters::nums_only?(nil)), 'Nil string')
    assert((not BeEF::Filters::nums_only?(1)), 'Is integer')
    assert((not BeEF::Filters::nums_only?("")), 'Empty string')
    assert((not BeEF::Filters::nums_only?("A")), 'First char is a alpha')
    assert((not BeEF::Filters::nums_only?("A3333")), '4 num chars begining with an aplha')
    assert((not BeEF::Filters::nums_only?("\x003333")), '4 num chars begining with a null')
    assert((not BeEF::Filters::nums_only?("}")), '} char')
    assert((not BeEF::Filters::nums_only?(".")), '. char')
    assert((not BeEF::Filters::nums_only?("+")), '+ char')
    assert((not BeEF::Filters::nums_only?("-")), '- char')
    assert((not BeEF::Filters::nums_only?("-1")), '-1 string')
    
    assert((BeEF::Filters::nums_only?("0")), 'First char is a num')
    assert((BeEF::Filters::nums_only?("3333")), '4 num chars')
  end
  
  def test_is_valid_float
    assert((not BeEF::Filters::is_valid_float?(nil)), 'Nil string')
    assert((not BeEF::Filters::is_valid_float?(1)), 'Is integer')
    assert((not BeEF::Filters::is_valid_float?("")), 'Empty string')
    assert((not BeEF::Filters::is_valid_float?("A")), 'First char is a alpha')
    assert((not BeEF::Filters::is_valid_float?("A3333")), '4 num chars begining with an aplha')
    assert((not BeEF::Filters::is_valid_float?("\x003333")), '4 num chars begining with a null')
    assert((not BeEF::Filters::is_valid_float?("}")), '} char')
    assert((not BeEF::Filters::is_valid_float?(".")), '. char')
    assert((not BeEF::Filters::is_valid_float?("+")), '+ char')
    assert((not BeEF::Filters::is_valid_float?("-")), '- char')
    assert((not BeEF::Filters::is_valid_float?("-1")), '-1 string')
    assert((not BeEF::Filters::is_valid_float?("0")), 'First char is a num')
    assert((not BeEF::Filters::is_valid_float?("3333")), '4 num chars')
    assert((not BeEF::Filters::is_valid_float?("0.A")), '0.A string')
    assert((BeEF::Filters::is_valid_float?("33.33")), '4 num chars')
    assert((BeEF::Filters::is_valid_float?("0.0")), '0.0 string')
    assert((BeEF::Filters::is_valid_float?("1.0")), '1.0 string')
    assert((BeEF::Filters::is_valid_float?("0.1")), '0.1 string')
    assert((BeEF::Filters::is_valid_float?("33.33")), '33.33 string')
  end
  
  def test_hexs_only
    assert((not BeEF::Filters::hexs_only?(nil)), 'Nil string')
    assert((not BeEF::Filters::hexs_only?(1)), 'Is integer')
    assert((not BeEF::Filters::hexs_only?("")), 'Empty string')
    assert((not BeEF::Filters::hexs_only?("\x003333")), '4 num chars begining with a null')
    assert((not BeEF::Filters::hexs_only?("}")), '} char')
    assert((not BeEF::Filters::hexs_only?(".")), '. char')
    assert((not BeEF::Filters::hexs_only?("+")), '+ char')
    assert((not BeEF::Filters::hexs_only?("-")), '- char')
    assert((not BeEF::Filters::hexs_only?("-1")), '-1 string')
    assert((not BeEF::Filters::hexs_only?("0.A")), '0.A string')
    assert((not BeEF::Filters::hexs_only?("33.33")), '4 num chars')
    assert((not BeEF::Filters::hexs_only?("0.0")), '0.0 string')
    assert((not BeEF::Filters::hexs_only?("1.0")), '1.0 string')
    assert((not BeEF::Filters::hexs_only?("0.1")), '0.1 string')
    assert((not BeEF::Filters::hexs_only?("33.33")), '33.33 string')
    
    assert((BeEF::Filters::hexs_only?("0123456789ABCDEFabcdef")), '0123456789ABCDEFabcdef string')
    assert((BeEF::Filters::hexs_only?("0")), 'First char is a num')
    assert((BeEF::Filters::hexs_only?("3333")), '4 num chars')
    assert((BeEF::Filters::hexs_only?("A3333")), '4 num chars begining with an aplha')
    assert((BeEF::Filters::hexs_only?("A")), 'First char is a alpha')
  end
  
  def test_first_char_is_num
    assert((not BeEF::Filters::first_char_is_num?("")), 'Empty string')
    assert((not BeEF::Filters::first_char_is_num?("A")), 'First char is a alpha')
    assert((not BeEF::Filters::first_char_is_num?("A3333")), '4 num chars begining with an aplha')
    assert((not BeEF::Filters::first_char_is_num?("\x003333")), '4 num chars begining with a null')
    
    assert((BeEF::Filters::first_char_is_num?("3333")), '4 num chars')
    assert((BeEF::Filters::first_char_is_num?("0AAAAAAAA")), '0AAAAAAAA string')
    assert((BeEF::Filters::first_char_is_num?("0")), 'First char is a num')
  end
  
  def test_has_whitespace_char
    assert((not BeEF::Filters::has_whitespace_char?("")), 'Empty string')
    assert((not BeEF::Filters::has_whitespace_char?("A")), 'First char is a alpha')
    assert((not BeEF::Filters::has_whitespace_char?("A3333")), '4 num chars begining with an aplha')
    assert((not BeEF::Filters::has_whitespace_char?("\x003333")), '4 num chars begining with a null')
    assert((not BeEF::Filters::has_whitespace_char?("0")), 'First char is a num')
    assert((not BeEF::Filters::has_whitespace_char?("}")), '} char')
    assert((not BeEF::Filters::has_whitespace_char?(".")), '. char')
    assert((not BeEF::Filters::has_whitespace_char?("+")), '+ char')
    assert((not BeEF::Filters::has_whitespace_char?("-")), '- char')
    assert((not BeEF::Filters::has_whitespace_char?("-1")), '-1 string')
    assert((not BeEF::Filters::has_whitespace_char?("0.A")), '0.A string')
    
    assert((BeEF::Filters::has_whitespace_char?("33 33")), '4 num chars')
    assert((BeEF::Filters::has_whitespace_char?(" ")), 'white space char only')
    assert((BeEF::Filters::has_whitespace_char?("                 ")), 'white space chars only')
    assert((BeEF::Filters::has_whitespace_char?(" 0AAAAAAAA")), 'white space at start of string')
    assert((BeEF::Filters::has_whitespace_char?(" 0AAAAAAAA ")), 'white space at start and end of string')
    assert((BeEF::Filters::has_whitespace_char?("\t0AAAAAAAA")), 'white space at start of string')
    assert((BeEF::Filters::has_whitespace_char?("\n0AAAAAAAA")), 'white space at start of string')
  end
  
  def test_alphanums_only
    assert((BeEF::Filters::alphanums_only?("A")), 'Single char')
    assert((BeEF::Filters::alphanums_only?("A3333")), '4 num chars begining with an aplha')
    assert((BeEF::Filters::alphanums_only?("0")), '0 string')

    assert((not BeEF::Filters::alphanums_only?(nil)), 'Nil')
    assert((not BeEF::Filters::alphanums_only?("")), 'Empty string')
    assert((not BeEF::Filters::alphanums_only?("\n")), '\\n string')
    assert((not BeEF::Filters::alphanums_only?("\r")), '\\r string')
    assert((not BeEF::Filters::alphanums_only?("\x01")), '0x01 string')
    assert((not BeEF::Filters::alphanums_only?("\xFF")), '0xFF string')
    assert((not BeEF::Filters::alphanums_only?("}")), '} char')
    assert((not BeEF::Filters::alphanums_only?(".")), '. char')
    assert((not BeEF::Filters::alphanums_only?("+")), '+ char')
    assert((not BeEF::Filters::alphanums_only?("-")), '- char')
    assert((not BeEF::Filters::alphanums_only?("-1")), '-1 string')
    assert((not BeEF::Filters::alphanums_only?("ee-!@$%^&*}=0.A")), '0.A string')
    assert((not BeEF::Filters::alphanums_only?("33 33")), '33 33 string')
    assert((not BeEF::Filters::alphanums_only?(" AAAAAAAA")), 'white space at start of string')
    assert((not BeEF::Filters::alphanums_only?("AAAAAAAA ")), 'white space at end of string')

    # check lowercase chars
    ('a'..'z').each {|c| 
      assert((BeEF::Filters::alphanums_only?(c)), 'lowercase chars')
    }
    
    # check uppercase chars
    ('A'..'Z').each {|c| 
      assert((BeEF::Filters::alphanums_only?(c)), 'uppercase chars')
    }
    
    # check numbers chars
    ('0'..'9').each {|c| 
      assert((BeEF::Filters::alphanums_only?(c)), 'number chars')
    }
      
    assert((not BeEF::Filters::alphanums_only?("\x00")), 'Single null')
    assert((not BeEF::Filters::alphanums_only?("A\x00")), 'Char and null')
    assert((not BeEF::Filters::alphanums_only?("AAAAAAAA\x00")), 'Char and null')
    assert((not BeEF::Filters::alphanums_only?("\x00A")), 'Null and char')
    assert((not BeEF::Filters::alphanums_only?("\x00AAAAAAAAA")), 'Null and chars')
    assert((not BeEF::Filters::alphanums_only?("A\x00A")), 'Null surrounded by chars')
    assert((not BeEF::Filters::alphanums_only?("AAAAAAAAA\x00AAAAAAAAA")), 'Null surrounded by chars')
    assert((not BeEF::Filters::alphanums_only?("A\n\r\x00")), 'new line and carriage return at start of string')
    assert((not BeEF::Filters::alphanums_only?("\x00\n\rA")), 'new line and carriage return at end of string')
    assert((not BeEF::Filters::alphanums_only?("A\n\r\x00\n\rA")), 'new line and carriage return at start and end of string')
    assert((not BeEF::Filters::alphanums_only?("\tA\x00A")), 'tab at start of string')


    (0..255).each {|c| 
      str = ''
      str.concat(c)
      str += "\x00"
      assert((not BeEF::Filters::alphanums_only?(str)), 'loop of behind every char')
    }

    (0..255).each {|c| 
      str = "\x00"
      str.concat(c)
      assert((not BeEF::Filters::alphanums_only?(str)), 'loop of behind every char')
    }

    (0..255).each {|c| 
      str = ''
      str.concat(c)
      str += "\x00"
      str.concat(c)
      assert((not BeEF::Filters::alphanums_only?(str)), 'loop of behind every char')
    }

    assert((BeEF::Filters::alphanums_only?("3333")), '33 33 string')

  end  
  
end
