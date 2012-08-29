#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
