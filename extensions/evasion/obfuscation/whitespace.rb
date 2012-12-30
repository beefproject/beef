#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
module BeEF
  module Extension
    module Evasion
      class Whitespace
        include Singleton

        def need_bootstrap
          true
        end
        
        def get_bootstrap
        # the decode function is in plain text - called IE-spacer - because trolling is always a good idea
        decode_function =
"//Dirty IE6 whitespace bug hack
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
}"
        end

        def execute(input, config)
          size = input.length
          encoded = encode(input)
          var_name = BeEF::Extension::Evasion::Helper::random_string(3)
          input = "var #{var_name}=\"#{encoded}\";[].constructor.constructor(IE_spacer(#{var_name}))();"
          print_debug "[OBFUSCATION - WHITESPACE] #{size}byte of Javascript code has been Whitespaced"
          input
        end

        def encode(input)                 
          output = input.unpack('B*') 
          output = output.to_s.gsub(/[\["01\]]/, '[' => '', '"' => '', ']' => '',  '0' => "\t", '1' => ' ')
          output
        end
      end
    end
  end
end
