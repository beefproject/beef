#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      class Whitespace
        include Singleton

        def need_bootstrap?
          true
        end

        def get_bootstrap
          # the decode function is in plain text - called IE-spacer - because trolling is always a good idea
          "//Dirty IE6 whitespace bug hack
if (typeof IE_spacer === 'function') {} else {
function IE_spacer(css_space) {
  var spacer = '';
  for(y = 0; y < css_space.length/8; y++)
  {
    v = 0;
    for(x = 0; x < 8; x++)
    {
      if(css_space.charCodeAt(x+(y*8)) > 9)
      {
        v++;
      }
      if(x != 7)
      {
        v = v << 1;
      }
    }
    spacer += String.fromCharCode(v);
  }return spacer;
}}"
        end

        def execute(input, _config)
          size = input.length
          encoded = encode(input)
          var_name = BeEF::Core::Crypto.random_alphanum_string(3)
          input = "var #{var_name}=\"#{encoded}\";[].constructor.constructor(IE_spacer(#{var_name}))();"
          print_debug "[OBFUSCATION - WHITESPACE] #{size} bytes of Javascript code has been Whitespaced"
          input
        end

        def encode(input)
          output = input.unpack('B*')
          output.to_s.gsub(/[\["01\]]/, '[' => '', '"' => '', ']' => '', '0' => "\t", '1' => ' ')
        end
      end
    end
  end
end
